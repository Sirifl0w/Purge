ARCHS = armv7 armv7s arm64
THEOS_BUILD_DIR = debs
export GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = Purge
Purge_FILES = Tweak.xm
Purge_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
SUBPROJECTS += purgeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
