# BatteryDynamicIsland（灵动岛电池温度展示）

一个基于 iOS 官方 **ActivityKit / WidgetKit**（灵动岛 Live Activity）的示例工程：左侧显示温度图标，右侧显示实时电池温度。

## 功能

- 通过 `ActivityKit` 启动 / 更新 / 结束灵动岛活动
- 灵动岛紧凑态：左侧温度图标（`thermometer.medium`），右侧实时温度
- 灵动岛展开态：展示图标、温度、电量、充电状态
- 锁屏横幅（Live Activity 卡片）同样展示温度与电量
- 主 App 提供「启动 / 结束」按钮，每 5 秒自动刷新温度

## 系统要求

- Xcode 15+，iOS 16.2+ 部署目标
- 真机运行（灵动岛仅存在于 iPhone 14 Pro 及更新机型；**Live Activity 不支持模拟器**）
- 需要开发者签名（个人免费账号即可）

## 重要说明：电池温度数据源

iOS **没有公开的电池温度读取 API**。`UIDevice` 仅能获取电量与充电状态。

因此本工程采用「数据源协议」抽象（`BatteryTemperatureProviding`），默认使用 `SimulatedTemperatureProvider`：

- 电量与充电状态：读取真实 `UIDevice` 数据
- 温度：充电时约 36°C、非充电约 30.5°C，并叠加正弦波动模拟实时变化

如需真实温度，实现 `BatteryTemperatureProviding` 协议（例如从外部 BLE 温度计 / 硬件通道取数），在 `BatteryMonitor.init` 处替换数据源即可，灵动岛代码无需改动。

## 工程结构

```
BatteryDynamicIsland/
├── BatteryDynamicIsland.xcodeproj/        # Xcode 工程
├── BatteryDynamicIsland/                  # App 主 Target
│   ├── BatteryDynamicIslandApp.swift      # App 入口
│   ├── ContentView.swift                  # 启动/结束按钮界面
│   ├── BatteryMonitor.swift               # Live Activity 生命周期管理
│   ├── TemperatureProvider.swift          # 温度数据源协议 + 模拟实现
│   ├── Assets.xcassets
│   └── Info.plist                         # 含 NSSupportsLiveActivities
├── BatteryDynamicIslandExtension/         # Widget 扩展 Target
│   ├── BatteryDynamicIslandExtension.swift # WidgetBundle 入口
│   ├── BatteryLiveActivity.swift          # Dynamic Island 布局
│   └── Info.plist
└── Shared/
    └── BatteryActivityAttributes.swift    # 共享属性（两个 Target 共同编译）
```

## 使用步骤

1. 用 Xcode 打开 `BatteryDynamicIsland.xcodeproj`
2. 选择主 Target，在 Signing & Capabilities 中选择你的 Team，修改 Bundle Identifier（扩展 Target 会自动跟随主 Bundle ID）
3. 连接真机（iOS 16.2+，iPhone 14 Pro 以上），选择设备后运行
4. 打开 App，点击「启动灵动岛」，回到桌面查看灵动岛效果；点击「结束灵动岛」移除
5. 长按灵动岛可展开查看详情

## 灵动岛布局说明

| 区域 | 内容 |
|------|------|
| 紧凑态 Leading | 温度图标 |
| 紧凑态 Trailing | 实时温度（如 `36.2°C`） |
| 展开态 Leading / Center / Trailing | 图标 / 温度数值 / 标题 |
| 展开态 Bottom | 温度标签 + 电量百分比 |
| Minimal | 温度图标 |

## 备注

- App 的 `Info.plist` 已配置 `NSSupportsLiveActivities = YES`，这是灵动岛能否启动的前提
- 上架 App Store 前需在 App 图标（Assets.xcassets/AppIcon）中放入 1024x1024 图标，并将推送能力按需接入（本示例使用本地 `Activity.update` 刷新，不依赖推送）
- Live Activity 单设备有数量限制（iOS 16 为 1 个/设备，iOS 18.2+ 可配置 5 个），代码中已做幂等处理（重复点击不会创建多个活动）
