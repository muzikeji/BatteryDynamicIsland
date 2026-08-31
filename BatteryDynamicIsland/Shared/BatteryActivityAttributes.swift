import ActivityKit

/// 灵动岛 Live Activity 的属性定义。
/// 该文件必须同时被 App 主 Target 和 Widget 扩展 Target 编译。
/// 注意：类型名与字段必须和越狱 tweak（BatteryIslandTweak/BatteryIsland.swift）中的定义完全一致，
/// 系统才能把 tweak 发起/更新的活动与这里的灵动岛 UI 模板正确匹配。
public struct BatteryActivityAttributes: ActivityAttributes {

    /// 每次更新时可变的状态数据。
    public struct ContentState: Codable, Hashable {
        /// 电池温度（摄氏度）
        public var temperature: Double
        /// 是否正在充电
        public var isCharging: Bool
    }
}
