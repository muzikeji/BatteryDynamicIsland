# BatteryIsland（灵动岛电池温度越狱插件）

一个 Theos 越狱 tweak：注入 SpringBoard，在灵动岛区域绘制自定义胶囊 overlay，左侧显示温度图标、右侧显示实时电池温度。**只安装 tweak 即可，无需宿主 App、无需 ActivityKit。**

## 技术原理

- 注入 SpringBoard，在 `applicationDidFinishLaunching` 后创建一个高层级 `UIWindow`（触摸穿透），在屏幕顶部中央绘制黑色圆角胶囊：左侧 `thermometer` 图标、右侧实时温度数字。
- 温度数据使用越狱环境下的 IOKit 私有 API `IOPSCopyPowerSourcesInfo` + `kIOPSTemperatureKey` 读取**真实电池温度**（非越狱环境无法读取）。
- 每 5 秒刷新一次；电池温度低于阈值时自动隐藏胶囊。
- 充电时温度图标变为绿色。

对比说明：旧的「注入 SpringBoard + ActivityKit 发起 Live Activity」方案实测不可用——Live Activity 的 UI 必须由注册了 `ActivityConfiguration` 的 Widget Extension 渲染，SpringBoard 没有，`Activity.request` 必然失败。自定义 overlay 不依赖 ActivityKit，是唯一"只装 tweak"即可全局生效的路径。

## 目录结构

```
BatteryIslandTweak/
├── control                  # deb 包元信息
├── Makefile                 # Theos 构建脚本
├── BatteryIsland.plist      # 注入目标过滤（com.apple.springboard）
├── Tweak.xm                 # Logos 源码：hook SpringBoard 启动 overlay
├── BatteryIslandOverlay.m   # ObjC：自定义灵动岛胶囊 overlay + 定时刷新 + 阈值控制
├── TemperatureReader.m      # ObjC：IOKit 真实温度读取
├── prefs/                   # 设置项（温度阈值），PreferenceBundle 子项目
└── layout/DEBIAN/postinst   # 安装脚本
```

## 前置条件

- 已越狱的 iPhone（iOS 15/16/17/18 均可，rootful 或 rootless 均可）
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

或把 deb 放入 Sileo / Zebra 直接安装。安装后重启 SpringBoard（respring）即可看到灵动岛胶囊。

## 设置

安装后可在「设置 → BatteryIsland」中调整：

- **电池温度达到多少度以上展示**（默认 20°C，范围 20–55°C）：电池温度达到该阈值以上时在灵动岛展示，低于阈值自动隐藏。

设置改动会即时生效（overlay 每 5 秒重新读取阈值）。

## 温度单位兼容

不同设备上 `kIOPSTemperatureKey` 返回值单位不一致（部分为摄氏度，部分为摄氏度 × 100）。`TemperatureReader.m` 已做兼容：数值 > 100 时按 `/ 100` 处理。

## 已知限制

- 胶囊为自定义绘制，不具备原生灵动岛的展开/动画/交互。
- 未做横屏适配（横屏时胶囊仍显示在屏幕顶部中央）。
- 锁屏时胶囊可能一并显示（取决于系统层级）。

## 注意事项

- 本插件仅用于个人已越狱设备的研究与学习用途。
