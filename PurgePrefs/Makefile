ARCHS = armv7 armv7s arm64

TARGET = iphone:clang:latest:5.0

THEOS_BUILD_DIR = Packages

include theos/makefiles/common.mk

BUNDLE_NAME = PurgePrefs
PurgePrefs_CFLAGS = -fno-objc-arc
PurgePrefs_FILES = PurgePrefsListController.m
PurgePrefs_INSTALL_PATH = /Library/PreferenceBundles
PurgePrefs_FRAMEWORKS = Foundation UIKit
PurgePrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PurgePrefs.plist$(ECHO_END)
