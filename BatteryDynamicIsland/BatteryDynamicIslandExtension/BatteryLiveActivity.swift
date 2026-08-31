import ActivityKit
import WidgetKit
import SwiftUI

/// 灵动岛 / 锁屏 Live Activity 界面。
struct BatteryLiveActivityView: View {

    let context: ActivityViewContext<BatteryActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: 30, weight: .medium))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("电池温度")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(temperatureText)
                    .font(.system(.title2, design: .rounded).monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()

            Label(context.state.isCharging ? "充电中" : "放电中",
                  systemImage: context.state.isCharging ? "battery.100percent.bolt" : "battery.75percent")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var temperatureText: String {
        String(format: "%.1f°C", context.state.temperature)
    }
}

/// 灵动岛 Live Activity Widget 注册入口。
/// 布局仿 Apple Music：展开态左右两侧对称（左侧温度图标、右侧实时温度），紧凑态左右各占一侧。
struct BatteryLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BatteryActivityAttributes.self) { context in
            BatteryLiveActivityView(context: context)
                .activityBackgroundTint(.black.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开态 - 左侧：温度图标
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(.orange)
                }
                // 展开态 - 右侧：实时温度 + 充电状态（两行，仿音乐 App 标题/副标题）
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(temperatureText(context))
                            .font(.system(.title3, design: .rounded).monospacedDigit())
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text(context.state.isCharging ? "充电中" : "放电中")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                // 紧凑态左侧：温度图标
                Image(systemName: "thermometer.medium")
                    .foregroundColor(.orange)
            } compactTrailing: {
                // 紧凑态右侧：实时温度
                Text(temperatureText(context))
                    .font(.system(.caption, design: .rounded).monospacedDigit())
                    .fontWeight(.semibold)
            } minimal: {
                Image(systemName: "thermometer.medium")
                    .foregroundColor(.orange)
            }
        }
    }

    private func temperatureText(_ context: ActivityViewContext<BatteryActivityAttributes>) -> String {
        String(format: "%.1f°C", context.state.temperature)
    }
}
