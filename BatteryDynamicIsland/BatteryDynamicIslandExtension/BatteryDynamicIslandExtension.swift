import WidgetKit
import SwiftUI

/// Widget 扩展的入口点。
@main
struct BatteryDynamicIslandBundle: WidgetBundle {
    var body: some Widget {
        BatteryLiveActivity()
    }
}
