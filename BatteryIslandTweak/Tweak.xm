#import <UIKit/UIKit.h>
#import "BatteryIslandOverlay.h"

// 方案说明：不依赖 ActivityKit / 宿主 App，
// 直接在 SpringBoard 顶部绘制自定义灵动岛胶囊 overlay（左温度图标、右实时温度）。
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[BatteryIsland] SpringBoard did finish launching");

    // 延迟启动，避免 SpringBoard 启动早期时序问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSLog(@"[BatteryIsland] overlay start begin");
        [[BatteryIslandOverlay sharedInstance] start];
        NSLog(@"[BatteryIsland] overlay start end");
    });
}

%end

%ctor {
    NSLog(@"[BatteryIsland] tweak loaded");
}
