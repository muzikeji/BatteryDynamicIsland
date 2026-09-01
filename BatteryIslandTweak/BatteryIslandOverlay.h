#import <UIKit/UIKit.h>

/// 在 SpringBoard 顶部绘制自定义灵动岛胶囊 overlay（左温度图标、右实时温度）。
/// 不依赖 ActivityKit / 宿主 App，纯越狱注入实现。
@interface BatteryIslandOverlay : NSObject

+ (instancetype)sharedInstance;

- (void)start;
- (void)stop;

@end
