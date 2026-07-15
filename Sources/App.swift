import SwiftUI
import AppKit
import Combine

@main
struct BreatheToolApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings { EmptyView() } }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    private var statusItem: NSStatusItem?
    private var breatheWindow: NSPanel?
    private let engine = BreathingEngine()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        createBreatheWindow()

        engine.$isCompactMode.sink { [weak self] _ in
            self?.resizeWindowForMode()
        }.store(in: &cancellables)
    }

    private func createBreatheWindow() {
        let contentView = ContentView().environmentObject(engine)
        let hostingView = NSHostingView(rootView: contentView)
        let panelSize = windowSize
        hostingView.frame = NSRect(origin: .zero, size: panelSize)

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = hostingView
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)) + 10)
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        panel.isMovableByWindowBackground = true
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false
        panel.delegate = self
        panel.alphaValue = engine.opacity
        panel.center()
        panel.makeKeyAndOrderFront(nil)

        breatheWindow = panel

        engine.$opacity
            .sink { [weak panel] val in panel?.alphaValue = val }
            .store(in: &cancellables)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }

    private var windowSize: NSSize {
        engine.isCompactMode ? NSSize(width: 200, height: 40) : NSSize(width: 180, height: 200)
    }

    private func resizeWindowForMode() {
        guard let panel = breatheWindow,
              let hosting = panel.contentView as? NSHostingView<ContentView> else { return }
        let size = windowSize
        hosting.frame.size = size
        panel.setContentSize(size)
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "lungs.fill", accessibilityDescription: "Breathe")
            button.toolTip = "呼吸练习"
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "显示 / 隐藏", action: #selector(toggleWindow), keyEquivalent: ""))

        let toggleItem = NSMenuItem(title: "开始", action: #selector(toggleBreathing), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)
        toggleMenuItem = toggleItem

        menu.addItem(.separator())

        menu.addItem(buildDurationItem(label: "吸气", current: engine.inhaleSeconds, action: #selector(setInhale(_:))))
        menu.addItem(buildDurationItem(label: "呼气", current: engine.exhaleSeconds, action: #selector(setExhale(_:))))
        menu.addItem(buildHoldItem())

        menu.addItem(.separator())

        let compactItem = NSMenuItem(title: "紧凑模式", action: #selector(toggleCompactMode), keyEquivalent: "")
        compactItem.state = engine.isCompactMode ? .on : .off
        menu.addItem(compactItem)
        compactMenuItem = compactItem

        let opacityHost = NSMenuItem()
        opacityHost.view = makeOpacityControl()
        menu.addItem(opacityHost)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    private func buildDurationItem(label: String, current: Int, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: "\(label): \(current) 秒", action: nil, keyEquivalent: "")
        let sub = NSMenu()
        for s in [2, 3, 4, 5, 6, 8, 10] {
            let opt = NSMenuItem(title: "\(s) 秒", action: action, keyEquivalent: "")
            opt.tag = s
            opt.state = (s == current) ? .on : .off
            sub.addItem(opt)
        }
        item.submenu = sub
        return item
    }

    private func buildHoldItem() -> NSMenuItem {
        let current = engine.holdSeconds
        let display = current == floor(current) ? String(format: "%.0f", current) : String(format: "%.1f", current)
        let item = NSMenuItem(title: "屏息: \(display) 秒", action: nil, keyEquivalent: "")
        let sub = NSMenu()
        for s in [0, 0.5, 1.0, 1.5, 2.0, 3.0] {
            let label = s == floor(s) ? String(format: "%.0f 秒", s) : String(format: "%.1f 秒", s)
            let opt = NSMenuItem(title: label, action: #selector(setHold(_:)), keyEquivalent: "")
            opt.tag = Int(s * 10)
            opt.state = (abs(s - current) < 0.01) ? .on : .off
            sub.addItem(opt)
        }
        item.submenu = sub
        return item
    }

    private func makeOpacityControl() -> NSView {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        let label = NSTextField(labelWithString: "透明度:")
        label.frame = NSRect(x: 8, y: 5, width: 55, height: 20)
        container.addSubview(label)

        let slider = NSSlider(frame: NSRect(x: 65, y: 4, width: 130, height: 22))
        slider.minValue = 0.2
        slider.maxValue = 1.0
        slider.doubleValue = engine.opacity
        slider.target = self
        slider.action = #selector(opacityChanged(_:))
        container.addSubview(slider)

        return container
    }

    private var toggleMenuItem: NSMenuItem?
    private var compactMenuItem: NSMenuItem?

    @objc private func toggleWindow() {
        guard let w = breatheWindow else { return }
        w.isVisible ? w.orderOut(nil) : w.makeKeyAndOrderFront(nil)
    }

    @objc private func toggleBreathing() {
        engine.toggle()
        toggleMenuItem?.title = engine.isRunning ? "暂停" : "开始"
    }

    @objc private func toggleCompactMode() {
        engine.isCompactMode.toggle()
        compactMenuItem?.state = engine.isCompactMode ? .on : .off
    }

    @objc private func setInhale(_ sender: NSMenuItem) {
        engine.inhaleSeconds = sender.tag
        rebuildStatusMenu()
    }

    @objc private func setExhale(_ sender: NSMenuItem) {
        engine.exhaleSeconds = sender.tag
        rebuildStatusMenu()
    }

    @objc private func setHold(_ sender: NSMenuItem) {
        engine.holdSeconds = Double(sender.tag) / 10.0
        rebuildStatusMenu()
    }

    @objc private func opacityChanged(_ sender: NSSlider) {
        engine.opacity = sender.doubleValue
    }

    private func rebuildStatusMenu() {
        statusItem?.menu = nil
        setupStatusItem()
    }
}
