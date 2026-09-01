export TARGET := iphone:clang:latest:16.1
export ARCHS = arm64 arm64e

# 安装方案，可被命令行覆盖：
#   THEOS_PACKAGE_SCHEME=rootless make package   # 无根越狱（/var/jb 前缀）
#   THEOS_PACKAGE_SCHEME=roothide make package   # Dopamine 2 / roothide（应用沙盒前缀）
# 默认 rootless
export THEOS_PACKAGE_SCHEME ?= rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BatteryIsland

BatteryIsland_FILES = Tweak.xm BatteryIslandOverlay.m TemperatureReader.m
BatteryIsland_CFLAGS = -fobjc-arc
BatteryIsland_FRAMEWORKS = UIKit IOKit

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk
