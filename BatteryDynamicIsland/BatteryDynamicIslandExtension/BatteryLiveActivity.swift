import ActivityKit
import WidgetKit
import SwiftUI

/// 灵动岛 / 锁屏 Live Activity 界面。
struct BatteryLiveActivityView: View {

    let context: ActivityViewContext<BatteryActivityAttributes>

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "thermometer.medium")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("电池温度")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(temperatureText)
                    .font(.system(.title3, design: .rounded).monospacedDigit())
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: context.state.isCharging ? "battery.100percent.bolt" : "battery.75percent")
                Text(context.state.isCharging ? "充电中" : "放电中")
            }
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
struct BatteryLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BatteryActivityAttributes.self) { context in
            BatteryLiveActivityView(context: context)
                .activityBackgroundTint(.black.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // 展开态 - 左上
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "thermometer.medium")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
                // 展开态 - 右上
                DynamicIslandExpandedRegion(.trailing) {
                    Text("电池温度")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                // 展开态 - 居中
                DynamicIslandExpandedRegion(.center) {
                    Text(temperatureText(context))
                        .font(.system(.title3, design: .rounded).monospacedDigit())
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                // 展开态 - 底部
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label("温度", systemImage: "thermometer.medium")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                        Text(context.state.isCharging ? "充电中" : "放电中")
                            .font(.caption)
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
                    .font(.system(.caption2, design: .rounded).monospacedDigit())
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
