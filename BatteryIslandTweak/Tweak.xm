#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static Class BatteryIslandManagerClass(void) {
    return NSClassFromString(@"BatteryIslandManager");
}

// 一次性给 SpringBoard 主 bundle 注入 NSSupportsLiveActivities，
// 让 ActivityKit 允许在当前进程发起 Live Activity。
// 相比 hook NSBundle 的 objectForInfoDictionaryKey:（SpringBoard 高频调用，易崩溃），
// 这里只在启动后一次性修改 infoDictionary，风险更低。
static void InjectLiveActivitiesSupport(void) {
    NSBundle *bundle = [NSBundle mainBundle];
    if (!bundle) {
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:bundle.infoDictionary];
    info[@"NSSupportsLiveActivities"] = @YES;

    Ivar ivar = class_getInstanceVariable([NSBundle class], "_infoDictionary");
    if (ivar) {
        object_setIvar(bundle, ivar, info);
        NSLog(@"[BatteryIsland] injected NSSupportsLiveActivities");
    } else {
        NSLog(@"[BatteryIsland] warn: _infoDictionary ivar not found");
    }
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    InjectLiveActivitiesSupport();

    // 延迟启动，避免 SpringBoard 启动早期时序问题
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        Class manager = BatteryIslandManagerClass();
        if (manager && [manager respondsToSelector:@selector(start)]) {
            [manager performSelector:@selector(start)];
        }
    });
}

%end

%ctor {
    NSLog(@"[BatteryIsland] tweak loaded");
}
