import ActivityKit
import Foundation
import UIKit

// 从 ObjC 侧（TemperatureReader.m）导入温度读取函数，避免在 iOS SDK 中引入不存在的 IOKit.ps 模块。
@_silgen_name("BI_batteryTemperature")
private func BI_batteryTemperature() -> Double

@_silgen_name("BI_isCharging")
private func BI_isCharging() -> Int32

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
            temperature: BI_batteryTemperature(),
            isCharging: BI_isCharging() != 0
        )
    }
}
