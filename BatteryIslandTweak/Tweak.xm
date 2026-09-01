#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// object_setIvar 不参与 ARC 引用计数，需用全局强引用持有注入的字典，
// 避免 autorelease 后悬垂指针导致 SpringBoard 崩溃。
static NSMutableDictionary *g_injectedInfo = nil;

// 一次性给 SpringBoard 主 bundle 注入 NSSupportsLiveActivities，
// 让 ActivityKit 允许在当前进程发起 Live Activity。
static void InjectLiveActivitiesSupport(void) {
    NSBundle *bundle = [NSBundle mainBundle];
    if (!bundle) {
        NSLog(@"[BatteryIsland] inject: no main bundle");
        return;
    }

    g_injectedInfo = [bundle.infoDictionary mutableCopy];
    g_injectedInfo[@"NSSupportsLiveActivities"] = @YES;

    Ivar ivar = class_getInstanceVariable([NSBundle class], "_infoDictionary");
    if (ivar) {
        object_setIvar(bundle, ivar, g_injectedInfo);
        // 读回验证注入是否生效（ActivityKit 是否真能读到该 key）
        id check = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSSupportsLiveActivities"];
        NSLog(@"[BatteryIsland] inject: NSSupportsLiveActivities injected, readback=%@", check);
    } else {
        NSLog(@"[BatteryIsland] inject: _infoDictionary ivar not found (skipped)");
    }
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    NSLog(@"[BatteryIsland] SpringBoard did finish launching");

    InjectLiveActivitiesSupport();

    // 延迟启动，避免 SpringBoard 启动早期时序问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        NSLog(@"[BatteryIsland] delayed start begin");
        Class manager = NSClassFromString(@"BatteryIslandManager");
        if (manager && [manager respondsToSelector:@selector(start)]) {
            [manager performSelector:@selector(start)];
            NSLog(@"[BatteryIsland] manager started");
        } else {
            NSLog(@"[BatteryIsland] manager class not found or no start selector");
        }
        NSLog(@"[BatteryIsland] delayed start end");
    });
}

%end

%ctor {
    NSLog(@"[BatteryIsland] tweak loaded");
}
