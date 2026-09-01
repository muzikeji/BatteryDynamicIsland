#import "BatteryIslandOverlay.h"
#import "TemperatureReader.h"

// 与 PreferenceBundle 一致的偏好设置 domain 与 key
static NSString *const kPreferencesAppID = @"com.muzikeji.batteryisland";
static NSString *const kThresholdKey = @"temperature_threshold";
static NSString *const kShowChargingKey = @"show_charging";

static const NSTimeInterval kRefreshInterval = 5.0;
static const CGFloat kCapsuleHeight = 37.0;
static const CGFloat kTopInset = 11.0;

@interface BatteryIslandOverlay ()
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIView *capsule;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *tempLabel;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation BatteryIslandOverlay

+ (instancetype)sharedInstance {
    static BatteryIslandOverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BatteryIslandOverlay alloc] init];
    });
    return instance;
}

- (void)start {
    if (self.window) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self buildWindow];
        [self scheduleTimer];
        [self refresh];
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timer invalidate];
        self.timer = nil;
        self.window.hidden = YES;
        self.window = nil;
        self.capsule = nil;
    });
}

#pragma mark - UI

- (void)buildWindow {
    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *sceneWindow = nil;
    for (UIScene *scene in app.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            sceneWindow = windowScene.windows.firstObject;
            break;
        }
    }

    CGRect screenBounds = [UIScreen mainScreen].bounds;
    UIWindow *window;
    if (sceneWindow.windowScene && [UIWindow instancesRespondToSelector:@selector(initWithWindowScene:)]) {
        window = [[UIWindow alloc] initWithWindowScene:sceneWindow.windowScene];
    } else {
        window = [[UIWindow alloc] initWithFrame:screenBounds];
    }
    window.frame = screenBounds;
    // 高于状态栏层级（UIWindowLevelStatusBar 已废弃，直接使用数值 1000），但不影响系统其它 UI；触摸穿透
    window.windowLevel = 1001.0;
    window.userInteractionEnabled = NO;
    window.hidden = NO;
    self.window = window;

    // 设置 rootViewController，保证 window 正确渲染子视图
    UIViewController *rootVC = [[UIViewController alloc] init];
    rootVC.view.backgroundColor = [UIColor clearColor];
    window.rootViewController = rootVC;

    CGFloat width = 150.0;
    CGFloat x = (screenBounds.size.width - width) / 2.0;

    UIView *capsule = [[UIView alloc] initWithFrame:CGRectMake(x, kTopInset, width, kCapsuleHeight)];
    capsule.backgroundColor = [UIColor blackColor];
    capsule.layer.cornerRadius = kCapsuleHeight / 2.0;
    capsule.clipsToBounds = YES;
    [rootVC.view addSubview:capsule];
    self.capsule = capsule;

    UIImage *icon = [UIImage systemImageNamed:@"thermometer.medium"];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
    iconView.tintColor = [UIColor systemOrangeColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.frame = CGRectMake(16.0, (kCapsuleHeight - 18.0) / 2.0, 18.0, 18.0);
    [capsule addSubview:iconView];
    self.iconView = iconView;

    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont monospacedDigitSystemFontOfSize:14.0 weight:UIFontWeightSemibold];
    label.textAlignment = NSTextAlignmentCenter;
    label.frame = CGRectMake(44.0, 0.0, width - 56.0, kCapsuleHeight);
    [capsule addSubview:label];
    self.tempLabel = label;
}

#pragma mark - Timer

- (void)scheduleTimer {
    [self.timer invalidate];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval
                                                  repeats:YES
                                                    block:^(NSTimer *timer) {
        [weakSelf refresh];
    }];
}

#pragma mark - Refresh

- (void)refresh {
    double temperature = BI_batteryTemperature();
    double threshold = [self threshold];

    // 温度读取失败：仍显示胶囊（便于区分"未显示"与"温度读不到"两种问题），内容显示占位符
    if (temperature < 0) {
        self.tempLabel.text = @"--°C";
        if (self.iconView) {
            self.iconView.tintColor = [UIColor systemOrangeColor];
        }
        self.window.hidden = NO;
        NSLog(@"[BatteryIsland] refresh: temperature read failed, showing placeholder");
        return;
    }

    if (temperature >= threshold) {
        self.tempLabel.text = [NSString stringWithFormat:@"%.1f°C", temperature];
        if (self.iconView) {
            self.iconView.tintColor = [self charging] ? [UIColor systemGreenColor] : [UIColor systemOrangeColor];
        }
        self.window.hidden = NO;
        NSLog(@"[BatteryIsland] refresh: temp=%.1f threshold=%.1f visible", temperature, threshold);
    } else {
        self.window.hidden = YES;
        NSLog(@"[BatteryIsland] refresh: temp=%.1f threshold=%.1f hidden (below threshold)", temperature, threshold);
    }
}

- (BOOL)charging {
    return BI_isCharging() != 0;
}

#pragma mark - Preferences

- (double)threshold {
    CFPropertyListRef value = CFPreferencesCopyAppValue((__bridge CFStringRef)kThresholdKey,
                                                        (__bridge CFStringRef)kPreferencesAppID);
    if (value) {
        NSNumber *number = (__bridge NSNumber *)value;
        double result = number.doubleValue;
        CFRelease(value);
        return result;
    }
    return 20.0;
}

@end
