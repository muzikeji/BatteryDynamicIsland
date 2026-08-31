#import "TemperatureReader.h"
#import <UIKit/UIKit.h>

// iOS 的 IOKit.framework 未公开 IOPowerSources.h 头文件，
// 这里手动声明符号，链接时由 IOKit.framework 提供（仅越狱环境可用）。
extern CFTypeRef IOPSCopyPowerSourcesInfo(void);
extern CFArrayRef IOPSCopyPowerSourcesList(CFTypeRef blob);
extern CFDictionaryRef IOPSGetPowerSourceDescription(CFTypeRef blob, CFTypeRef source);

double BI_batteryTemperature(void) {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    if (!blob) {
        return -1;
    }
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    if (!sources) {
        CFRelease(blob);
        return -1;
    }

    double result = -1;
    CFIndex count = CFArrayGetCount(sources);
    for (CFIndex i = 0; i < count; i++) {
        CFTypeRef source = CFArrayGetValueAtIndex(sources, i);
        CFDictionaryRef description = IOPSGetPowerSourceDescription(blob, source);
        if (!description) {
            continue;
        }
        CFNumberRef tempNumber = CFDictionaryGetValue(description, CFSTR("Temperature"));
        if (tempNumber && CFGetTypeID(tempNumber) == CFNumberGetTypeID()) {
            int value = 0;
            if (CFNumberGetValue(tempNumber, kCFNumberIntType, &value)) {
                double doubleValue = (double)value;
                // 单位兼容：部分设备返回摄氏度，部分返回摄氏度 * 100
                result = doubleValue > 100 ? doubleValue / 100.0 : doubleValue;
                break;
            }
        }
    }

    CFRelease(sources);
    CFRelease(blob);
    return result;
}

int BI_isCharging(void) {
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    UIDeviceBatteryState state = device.batteryState;
    return (state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull) ? 1 : 0;
}
