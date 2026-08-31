#import "BatteryIslandPrefsRootListController.h"

// 与 tweak 侧一致的偏好设置 domain 与 key
static NSString *const kPreferencesAppID = @"com.muzikeji.batteryisland";
static NSString *const kThresholdKey = @"temperature_threshold";

@interface PSSpecifier : NSObject
- (id)propertyForKey:(NSString *)key;
- (void)setProperty:(id)property forKey:(NSString *)key;
@end

@implementation BatteryIslandPrefsRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    CFPropertyListRef value = CFPreferencesCopyAppValue((__bridge CFStringRef)key,
                                                        (__bridge CFStringRef)kPreferencesAppID);
    if (value) {
        return CFBridgingRelease(value);
    }
    return [specifier propertyForKey:@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:@"key"];
    CFPreferencesSetAppValue((__bridge CFStringRef)key,
                             (__bridge CFPropertyListRef)value,
                             (__bridge CFStringRef)kPreferencesAppID);
    CFPreferencesAppSynchronize((__bridge CFStringRef)kPreferencesAppID);

    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.muzikeji.batteryisland.prefsChanged"),
        NULL, NULL, true);
}

@end
