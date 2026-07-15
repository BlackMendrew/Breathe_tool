APP_NAME    := BreatheTool
BUNDLE      := $(APP_NAME).app
MACOS_DIR   := $(BUNDLE)/Contents/MacOS
RES_DIR     := $(BUNDLE)/Contents/Resources
SWIFT_FILES := Sources/App.swift Sources/ContentView.swift Sources/BreathingEngine.swift
SDK_PATH    := $(shell xcrun --show-sdk-path --sdk macosx)
ARCH        := $(shell uname -m)

.PHONY: all run clean

all: $(BUNDLE)

$(BUNDLE): $(SWIFT_FILES) Info.plist
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
	@echo "Done: $(BUNDLE)"

run: $(BUNDLE)
	open $(BUNDLE)

clean:
	rm -rf $(BUNDLE)
