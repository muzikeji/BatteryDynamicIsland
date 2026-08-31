#import <UIKit/UIKit.h>

@class PSSpecifier;

// Preferences 框架为私有框架，Theos 不提供对应头文件，这里按越狱社区惯例内联声明所需接口，
// 符号在链接期由 Preferences.framework 提供。
@interface PSViewController : UIViewController
@end

@interface PSListController : PSViewController {
    NSArray *_specifiers;
}
@property (nonatomic, retain) NSArray *specifiers;
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(PSListController *)target;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
@end

@interface BatteryIslandPrefsRootListController : PSListController
@end
