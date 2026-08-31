import UIKit

/// 电池温度数据源协议。
/// iOS 未提供公开的电池温度读取 API（`UIDevice` 只能拿到电量与充电状态），
/// 因此通过协议抽象数据来源，便于后续替换为真实数据源。
protocol BatteryTemperatureProviding {
    /// 当前电量 0.0 ~ 1.0
    var batteryLevel: Double { get }
    /// 当前电池温度（摄氏度）
    var batteryTemperature: Double { get }
    /// 是否正在充电
    var isCharging: Bool { get }
}

/// 模拟数据源：结合真实电量/充电状态，温度在充电时偏高并随时间小幅波动。
/// 若后续拿到真实温度（如外部 BLE 温度计），实现 `BatteryTemperatureProviding` 替换即可。
struct SimulatedTemperatureProvider: BatteryTemperatureProviding {

    var batteryLevel: Double {
        let level = UIDevice.current.batteryLevel
        return level >= 0 ? level : 0.75
    }

    var isCharging: Bool {
        let state = UIDevice.current.batteryState
        return state == .charging || state == .full
    }

    var batteryTemperature: Double {
        let base = isCharging ? 36.0 : 30.5
        let wave = sin(Date().timeIntervalSince1970 / 18.0) * 1.5
        return base + wave
    }
}
