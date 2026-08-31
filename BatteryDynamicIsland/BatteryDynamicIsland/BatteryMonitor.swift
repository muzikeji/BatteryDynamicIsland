import ActivityKit
import UIKit

/// 管理 Live Activity 的完整生命周期：启动、更新、结束。
final class BatteryMonitor {

    static let shared = BatteryMonitor()

    private var currentActivity: Activity<BatteryActivityAttributes>?
    private var timer: Timer?
    private let provider: BatteryTemperatureProviding

    /// 当前是否已有运行中的灵动岛活动
    var isActive: Bool { currentActivity != nil }

    init(provider: BatteryTemperatureProviding = SimulatedTemperatureProvider()) {
        self.provider = provider
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    /// 启动灵动岛，并开始周期性刷新温度。
    func start() {
        guard currentActivity == nil else { return }

        let attributes = BatteryActivityAttributes(deviceName: UIDevice.current.name)
        let initialState = makeContentState()

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            scheduleUpdates()
            print("灵动岛已启动")
        } catch {
            print("启动灵动岛失败: \(error.localizedDescription)")
        }
    }

    /// 结束灵动岛活动。
    func stop() {
        timer?.invalidate()
        timer = nil
        let activity = currentActivity
        currentActivity = nil
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
        print("灵动岛已结束")
    }

    private func scheduleUpdates() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }

    /// 用最新数据更新灵动岛。
    private func refresh() {
        Task {
            await currentActivity?.update(ActivityContent(state: makeContentState(), staleDate: nil))
        }
    }

    private func makeContentState() -> BatteryActivityAttributes.ContentState {
        BatteryActivityAttributes.ContentState(
            batteryLevel: provider.batteryLevel,
            batteryTemperature: provider.batteryTemperature,
            isCharging: provider.isCharging
        )
    }
}
