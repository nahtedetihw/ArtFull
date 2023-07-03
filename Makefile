export TARGET=iphone:14.5:14.5
INSTALL_TARGET_PROCESSES = Music

DEBUG = 0

FINALPACKAGE = 1

THEOS_PACKAGE_SCHEME=rootless

SYSROOT=$(THEOS)/sdks/iphoneos14.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ArtFull

ArtFull_FILES = Tweak.xm
ArtFull_CFLAGS = -fobjc-arc
ArtFull_LDFLAGS = -ld64

include $(THEOS_MAKE_PATH)/tweak.mk
