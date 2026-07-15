APP_NAME    := BreatheTool
BUNDLE      := $(APP_NAME).app
MACOS_DIR   := $(BUNDLE)/Contents/MacOS
RES_DIR     := $(BUNDLE)/Contents/Resources
SWIFT_FILES := Sources/App.swift Sources/ContentView.swift Sources/BreathingEngine.swift
SDK_PATH    := $(shell xcrun --show-sdk-path --sdk macosx)
ARCH        := $(shell uname -m)
ICON_SET    := AppIcon.iconset
ICON_FILE   := BreatheTool.icns
DMG_FILE    := $(APP_NAME).dmg
DMG_STAGING := /tmp/dmg_$(APP_NAME)

.PHONY: all run clean dmg

all: $(BUNDLE)

# --- App Bundle ---
$(BUNDLE): $(SWIFT_FILES) Info.plist $(ICON_FILE)
	@echo "Building $(APP_NAME) for $(ARCH)..."
	@rm -rf $(BUNDLE)
	@mkdir -p $(MACOS_DIR) $(RES_DIR)
	swiftc \
		-sdk $(SDK_PATH) \
		-target $(ARCH)-apple-macos14.0 \
		-framework SwiftUI \
		-framework AppKit \
		-framework Combine \
		-O \
		-o $(MACOS_DIR)/$(APP_NAME) \
		$(SWIFT_FILES)
	@cp Info.plist $(BUNDLE)/Contents/
	@cp $(ICON_FILE) $(RES_DIR)/
	@codesign --force --deep --sign - $(BUNDLE)
	@echo "Done: $(BUNDLE)"

# --- App Icon ---
$(ICON_FILE): $(ICON_SET)
	iconutil -c icns $(ICON_SET) -o $(ICON_FILE)
	@echo "Icon created: $(ICON_FILE)"

$(ICON_SET): /tmp/make_icon.swift
	@mkdir -p $(ICON_SET)
	xcrun swiftc -sdk $(SDK_PATH) -framework AppKit -O -o /tmp/make_icon /tmp/make_icon.swift
	/tmp/make_icon
	sips -z 16 16   /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_16x16.png
	sips -z 32 32   /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_16x16@2x.png
	sips -z 32 32   /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_32x32.png
	sips -z 64 64   /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_32x32@2x.png
	sips -z 128 128 /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_128x128.png
	sips -z 256 256 /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_128x128@2x.png
	sips -z 256 256 /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_256x256.png
	sips -z 512 512 /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_256x256@2x.png
	sips -z 512 512 /tmp/AppIcon_1024.png --out $(ICON_SET)/icon_512x512.png
	cp /tmp/AppIcon_1024.png $(ICON_SET)/icon_512x512@2x.png
	@echo "Iconset ready"

# --- DMG with Applications symlink ---
dmg: $(BUNDLE)
	@rm -rf $(DMG_STAGING) $(DMG_FILE)
	@mkdir -p $(DMG_STAGING)
	@cp -R $(BUNDLE) $(DMG_STAGING)/
	@ln -s /Applications $(DMG_STAGING)/Applications
	hdiutil create -volname "$(APP_NAME)" \
		-srcfolder $(DMG_STAGING) \
		-ov -format UDZO \
		$(DMG_FILE)
	@rm -rf $(DMG_STAGING)
	@echo "DMG created: $(DMG_FILE)"

run: $(BUNDLE)
	open $(BUNDLE)

clean:
	rm -rf $(BUNDLE) $(DMG_FILE) $(ICON_FILE) $(ICON_SET)
