TARGET = iphone:9.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Ambiance
Ambiance_FILES = AmbianceRootListController.m $(wildcard ../DPHue/*.m) $(wildcard ../CocoaAsyncSocket/*.m)
Ambiance_INSTALL_PATH = /Library/PreferenceBundles
Ambiance_FRAMEWORKS = UIKit
Ambiance_PRIVATE_FRAMEWORKS = Preferences
Ambiance_LIBRARIES = CepheiPrefs Cephei

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Ambiance.plist$(ECHO_END)
