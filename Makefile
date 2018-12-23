include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Ambiance
Ambiance_FILES = Tweak.xm $(wildcard DPHue/*.m) $(wildcard CocoaAsyncSocket/*.m) LEColorPicker/LEColorPicker.m libfollow/libfollow.m
Ambiance_LIBRARIES = Cephei activator
Ambiance_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += ambiance
include $(THEOS_MAKE_PATH)/aggregate.mk
