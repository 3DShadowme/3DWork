ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = FilamentManager

FilamentManager_FILES = src/main.m \
                        src/AppDelegate.m \
                        src/Helpers.m \
                        src/FilamentItem.m \
                        src/FilamentStore.m \
                        src/ListViewController.m \
                        src/EditViewController.m

FilamentManager_FRAMEWORKS = UIKit Foundation
FilamentManager_INFOPLIST_FILE = layout/Applications/FilamentManager.app/Info.plist

include $(THEOS_MAKE_PATH)/application.mk

# 编译后自动把 .app 打成 TrollStore 可用的 .tipa 包
after-package::
	@bash ./package_tipa.sh
