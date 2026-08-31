import UIKit

/// 电池温度数据源协议。
/// 真实电池温度只能通过越狱环境下的 IOKit 私有 API 读取（见 BatteryIslandTweak/BatteryIsland.swift）。
/// 本 App 工程用 Xcode 官方 SDK 编译，无法直接导入 IOKit 私有头，因此通过协议抽象，
/// 默认使用模拟实现；在越狱设备上实际由 tweak 注入 SpringBoard 读取真实温度并更新灵动岛。
protocol BatteryTemperatureProviding {
    /// 当前电池温度（摄氏度）
    var temperature: Double { get }
    /// 是否正在充电
    var isCharging: Bool { get }
}

/// 模拟数据源：充电时温度偏高并随时间小幅波动。
struct SimulatedTemperatureProvider: BatteryTemperatureProviding {

    var isCharging: Bool {
        let state = UIDevice.current.batteryState
        return state == .charging || state == .full
    }

    var temperature: Double {
        let base = isCharging ? 36.0 : 30.5
        let wave = sin(Date().timeIntervalSince1970 / 18.0) * 1.5
        return base + wave
    }
}
