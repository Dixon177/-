ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AhmedBypass
AhmedBypass_FILES = Tweak.x
AhmedBypass_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
