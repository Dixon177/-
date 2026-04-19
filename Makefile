ARCHS = arm64 arm64e

TWEAK_NAME = AhmedBypass
AhmedBypass_FILES = Tweak.x
AhmedBypass_FRAMEWORKS = UIKit Foundation
AhmedBypass_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
	install.exec "uicache"
