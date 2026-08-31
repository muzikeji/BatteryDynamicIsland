import ActivityKit
import Foundation
import IOKit.ps
import UIKit

/// 灵动岛 Live Activity 属性。
/// 注意：类型名与字段必须和配套宿主 App 的 Widget 扩展中的定义完全一致，
/// 系统才能把本 tweak 发起/更新的活动与灵动岛 UI 模板正确匹配。
public struct BatteryActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var temperature: Double
        public var isCharging: Bool
    }
}

/// 电池温度/充电状态的读取与灵动岛生命周期管理。
/// 通过 @objc 暴露给 Logos 层（Tweak.xm）调用。
@objc(BatteryIslandManager)
public final class BatteryIslandManager: NSObject {

    private static var timer: Timer?

    @objc
    public static func start() {
        guard timer == nil else { return }
        UIDevice.current.isBatteryMonitoringEnabled = true

        let attributes = BatteryActivityAttributes()
        let initialState = makeContentState()

        do {
            _ = try Activity<BatteryActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            NSLog("[BatteryIsland] Live Activity started")
        } catch {
            NSLog("[BatteryIsland] request failed: %@", error.localizedDescription)
        }

        let timer = Timer(timeInterval: 5.0, repeats: true) { _ in
            let newState = makeContentState()
            for activity in Activity<BatteryActivityAttributes>.activities {
                Task {
                    await activity.update(ActivityContent(state: newState, staleDate: nil))
                }
            }
        }
        timer.tolerance = 1.0
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    @objc
    public static func stop() {
        timer?.invalidate()
        timer = nil
        for activity in Activity<BatteryActivityAttributes>.activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }

    private static func makeContentState() -> BatteryActivityAttributes.ContentState {
        BatteryActivityAttributes.ContentState(
            temperature: readBatteryTemperature(),
            isCharging: UIDevice.current.batteryState == .charging
                || UIDevice.current.batteryState == .full
        )
    }

    /// 通过 IOKit 私有 API 读取真实电池温度（仅越狱环境可用）。
    /// 单位兼容处理：部分设备返回摄氏度，部分返回摄氏度 * 100。
    private static func readBatteryTemperature() -> Double {
        guard let blob = IOPSCopyPowerSourcesInfo() else { return -1 }
        defer { CFRelease(blob) }
        guard let sources = IOPSCopyPowerSourcesList(blob) else { return -1 }
        defer { CFRelease(sources) }

        let key = "Temperature" as CFString
        let count = CFArrayGetCount(sources)
        for index in 0..<count {
            let source = CFArrayGetValueAtIndex(sources, index)
            guard let description = IOPSGetPowerSourceDescription(blob, source) else { continue }
            guard let raw = CFDictionaryGetValue(description, Unmanaged.passUnretained(key).toOpaque()) else {
                continue
            }
            let number = unsafeBitCast(raw, to: CFNumber.self)
            var value: Int = 0
            guard CFNumberGetValue(number, .intType, &value) else { continue }
            let doubleValue = Double(value)
            return doubleValue > 100 ? doubleValue / 100.0 : doubleValue
        }
        return -1
    }
}
