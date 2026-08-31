export TARGET := iphone:clang:latest:16.1
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BatteryIsland

BatteryIsland_FILES = Tweak.xm BatteryIsland.swift
BatteryIsland_CFLAGS = -fobjc-arc
BatteryIsland_FRAMEWORKS = UIKit IOKit ActivityKit
BatteryIsland_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk
