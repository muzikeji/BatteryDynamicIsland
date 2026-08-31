include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = BatteryIslandPrefs
BatteryIslandPrefs_FILES = BatteryIslandPrefsRootListController.m
BatteryIslandPrefs_INSTALL_PATH = /Library/PreferenceBundles
BatteryIslandPrefs_FRAMEWORKS = UIKit Foundation
# Preferences 为私有框架，新版 iOS SDK 已无其 tbd，链接期无法找到。
# 用 -undefined dynamic_lookup 让 PSListController / PSViewController 等符号
# 在运行时由 PreferenceLoader 已加载的 Preferences.framework 解析。
BatteryIslandPrefs_LDFLAGS = -Wl,-undefined,dynamic_lookup

include $(THEOS_MAKE_PATH)/bundle.mk
