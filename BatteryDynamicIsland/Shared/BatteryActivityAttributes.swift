import ActivityKit

/// 灵动岛 Live Activity 的属性定义。
/// 该文件必须同时被 App 主 Target 和 Widget 扩展 Target 编译。
struct BatteryActivityAttributes: ActivityAttributes {

    /// 每次更新时可变的状态数据。
    struct ContentState: Codable, Hashable {
        /// 电池电量 0.0 ~ 1.0
        var batteryLevel: Double
        /// 电池温度（摄氏度）
        var batteryTemperature: Double
        /// 是否正在充电
        var isCharging: Bool
    }

    /// 活动启动时固定不变的属性。
    var deviceName: String
}
