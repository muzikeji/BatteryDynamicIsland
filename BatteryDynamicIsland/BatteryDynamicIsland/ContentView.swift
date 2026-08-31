import SwiftUI

struct ContentView: View {

    @State private var currentTemperature: Double = 0
    @State private var isActive = BatteryMonitor.shared.isActive

    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "thermometer.medium")
                    .font(.system(size: 44))
                    .foregroundColor(.orange)

                Text(temperatureText)
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                Text(isActive ? "灵动岛展示中" : "灵动岛未启动")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(spacing: 12) {
                Button(isActive ? "结束灵动岛" : "启动灵动岛") {
                    if isActive {
                        BatteryMonitor.shared.stop()
                    } else {
                        BatteryMonitor.shared.start()
                    }
                    isActive = BatteryMonitor.shared.isActive
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Text("仅支持 iOS 16.1+，且需要在真机上查看")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
        }
        .onReceive(timer) { _ in
            currentTemperature = SimulatedTemperatureProvider().batteryTemperature
            isActive = BatteryMonitor.shared.isActive
        }
    }

    private var temperatureText: String {
        String(format: "%.1f°C", currentTemperature)
    }
}
