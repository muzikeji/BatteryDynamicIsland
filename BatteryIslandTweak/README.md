# BatteryIsland（灵动岛电池温度越狱插件）

一个 Theos 越狱 tweak：注入 SpringBoard，在灵动岛左侧显示温度图标、右侧显示实时电池温度。

## 技术原理

灵动岛（Live Activity）由两个角色配合完成：

1. **UI 模板提供者**：一个包含 `ActivityConfiguration` 的 Widget 扩展（在配套宿主 App 工程 `../BatteryDynamicIsland` 中），负责灵动岛的布局渲染。
2. **活动发起/更新者**：本 tweak 注入 SpringBoard，调用 `ActivityKit` 的 `Activity.request` 发起活动，并用定时器每 5 秒 `update` 刷新温度。

温度数据使用越狱环境下的 IOKit 私有 API `IOPSCopyPowerSourcesInfo` + `kIOPSTemperatureKey` 读取**真实电池温度**（非越狱环境无法读取）。

关键点：

- SpringBoard 默认 `Info.plist` 不含 `NSSupportsLiveActivities`，本 tweak 通过 hook `NSBundle` 的 `objectForInfoDictionaryKey:` 在运行时让 ActivityKit 认为当前进程支持 Live Activities（rootless 越狱下系统卷只读，runtime hook 比改 plist 更可靠）。
- `BatteryActivityAttributes` 的类型名与 `ContentState` 字段（`temperature`、`isCharging`）必须与宿主 App 的 Widget 扩展中的定义**完全一致**，否则系统无法匹配 UI 模板。

## 目录结构

```
BatteryIslandTweak/
├── control                  # deb 包元信息
├── Makefile                 # Theos 构建脚本
├── BatteryIsland.plist      # 注入目标过滤（com.apple.springboard）
├── Tweak.xm                 # Logos 源码：hook NSBundle / SpringBoard
├── BatteryIsland.swift      # Swift：ActivityKit 生命周期 + IOKit 温度读取
└── layout/DEBIAN/postinst   # rootful 兜底：写入 NSSupportsLiveActivities
```

## 前置条件

- 已越狱的 iPhone（iOS 16.1+，灵动岛机型：iPhone 14 Pro 及以上），rootful 或 rootless 均可
- 配套宿主 App（`../BatteryDynamicIsland`）已安装，其 Widget 扩展已注册（用于提供灵动岛 UI）
- 构建机安装 [Theos](https://github.com/theos/theos)（含 iOS 16.1+ SDK）

## 构建

```bash
# 确保环境变量指向 Theos
export THEOS=~/theos

# 打包成 deb
make package

# 生成 .deb 位于 ./packages/ 目录
```

## 安装

```bash
# 将 deb 传送到设备后，通过 ssh 安装
scp packages/*.deb root@<设备IP>:/tmp/
ssh root@<设备IP> dpkg -i /tmp/*.deb
```

或把 deb 放入 Sileo / Zebra 直接安装。安装后重启 SpringBoard（respring）即可看到灵动岛效果。

## 温度单位兼容

不同设备上 `kIOPSTemperatureKey` 返回值单位不一致（部分为摄氏度，部分为摄氏度 × 100）。`BatteryIsland.swift` 的 `readBatteryTemperature()` 已做兼容：数值 > 100 时按 `/ 100` 处理。

## 注意事项

- 若灵动岛不显示，先确认配套宿主 App 已安装且其 Widget 已注册（在设置中查看该 App 是否出现在灵动岛/锁定屏幕的活动中）。
- tweak 与宿主 App 两侧的 `BatteryActivityAttributes` 结构必须保持同步；改字段时需同时改 `BatteryIsland.swift` 与 `BatteryDynamicIsland/Shared/BatteryActivityAttributes.swift`。
- 本插件仅用于个人已越狱设备的研究与学习用途。
