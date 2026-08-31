#import <UIKit/UIKit.h>

static Class BatteryIslandManagerClass(void) {
    return NSClassFromString(@"BatteryIslandManager");
}

// 让 ActivityKit 认为当前进程（SpringBoard）支持 Live Activities。
// 相比修改系统 Info.plist，runtime hook 对 rootless 越狱（iOS 15+ 只读系统卷）更可靠。
%hook NSBundle

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"NSSupportsLiveActivities"] && self == [NSBundle mainBundle]) {
        return @YES;
    }
    return %orig;
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    Class manager = BatteryIslandManagerClass();
    if (manager && [manager respondsToSelector:@selector(start)]) {
        [manager performSelector:@selector(start)];
    }
}

%end

%ctor {
    NSLog(@"[BatteryIsland] tweak loaded");
}
