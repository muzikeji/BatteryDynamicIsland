import ActivityKit
import Foundation
import UIKit

// 从 ObjC 侧（TemperatureReader.m）导入温度读取函数，避免在 iOS SDK 中引入不存在的 IOKit.ps 模块。
@_silgen_name("BI_batteryTemperature")
private func BI_batteryTemperature() -> Double

@_silgen_name("BI_isCharging")
private func BI_isCharging() -> Int32

/// 偏好设置 key 与 domain（与 PreferenceBundle 一致）。
private let kPreferencesAppID = "com.muzikeji.batteryisland" as CFString
private let kThresholdKey = "temperature_threshold" as CFString

/// 灵动岛 Live Activity 属性。
/// 注意：类型名与字段必须和配套宿主 App 的 Widget 扩展中的定义完全一致。
public struct BatteryActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var temperature: Double
        public var isCharging: Bool
    }
}

/// 电池温度/充电状态的读取与灵动岛生命周期管理。
@objc(BatteryIslandManager)
public final class BatteryIslandManager: NSObject {

    private static var timer: DispatchSourceTimer?

    @objc
    public static func start() {
        guard timer == nil else { return }
        UIDevice.current.isBatteryMonitoringEnabled = true

        NSLog("[BatteryIsland] start, threshold=%@, temperature=%@",
              String(format: "%.1f", threshold()),
              String(format: "%.1f", BI_batteryTemperature()))

        // 首次检查：温度达标才展示灵动岛
        evaluate()

        let queue = DispatchQueue(label: "com.muzikeji.batteryisland.timer")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 5.0, repeating: 5.0)
        timer.setEventHandler {
            evaluate()
        }
        timer.resume()
        self.timer = timer
    }

    /// 根据温度阈值决定展示 / 更新 / 结束灵动岛。
    private static func evaluate() {
        let temperature = BI_batteryTemperature()
        let charging = BI_isCharging() != 0
        let threshold = threshold()
        let activities = Activity<BatteryActivityAttributes>.activities

        if temperature >= threshold {
            let state = BatteryActivityAttributes.ContentState(
                temperature: temperature,
                isCharging: charging
            )
            if activities.isEmpty {
                requestActivity(state: state)
            } else {
                for activity in activities {
                    Task {
                        await activity.update(using: state)
                    }
                }
            }
        } else {
            for activity in activities {
                Task {
                    await activity.end(using: nil, dismissalPolicy: .immediate)
                }
            }
        }
    }

    private static func requestActivity(state: BatteryActivityAttributes.ContentState) {
        let attributes = BatteryActivityAttributes()
        do {
            _ = try Activity<BatteryActivityAttributes>.request(
                attributes: attributes,
                contentState: state,
                pushType: nil
            )
            NSLog("[BatteryIsland] activity started")
        } catch {
            NSLog("[BatteryIsland] request failed: %@", error.localizedDescription)
        }
    }

    /// 读取用户设置的温度阈值（摄氏度），默认 35.0。
    private static func threshold() -> Double {
        if let value = CFPreferencesCopyAppValue(kThresholdKey, kPreferencesAppID) {
            if let number = value as? NSNumber {
                return number.doubleValue
            }
            if let string = value as? NSString {
                return string.doubleValue
            }
        }
        return 35.0
    }
}
