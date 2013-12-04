export GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = Purge
Purge_FILES = Tweak.xm
Purge_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
