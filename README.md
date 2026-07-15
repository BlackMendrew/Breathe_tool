# 🫁 BreatheTool

A minimal, always-on-top breathing exercise tool for macOS.  
macOS 悬浮置顶呼吸法练习工具。

<p align="center">
  <img src="screenshots/idle.png" width="180" alt="Idle state" />
  <img src="screenshots/inhale.png" width="180" alt="Inhale phase" />
  <img src="screenshots/exhale.png" width="180" alt="Exhale phase" />
</p>

## Features / 功能

- **Always on top** — floats above all windows, including fullscreen apps
- **Click to start/stop** — tap the window center, no buttons needed
- **Configurable breathing rhythm** — set inhale & exhale durations independently (2—10s)
- **Color-coded phases** — blue during inhale, warm orange during exhale
- **Adjustable opacity** — transparency slider in the menu bar
- **Minimal UI** — no title bar, no buttons, just a breathing circle
- **Status bar menu** — all settings accessible from the menu bar 🫁 icon
- **Works on all spaces** — stays visible even on fullscreen/other desktop spaces

---

## Screenshots / 截图

| Idle | Inhale | Exhale |
|------|--------|--------|
| ![idle](screenshots/idle.png) | ![inhale](screenshots/inhale.png) | ![exhale](screenshots/exhale.png) |

---

## Installation / 安装

### Download DMG (Recommended)

1. Go to [Releases](https://github.com/BlackMendrew/Breathe_tool/releases)
2. Download `BreatheTool.dmg`
3. Open the DMG and drag `BreatheTool.app` to your `/Applications` folder
4. Right-click → **Open** the first time (unsigned app — see below)

> ⚠️ This app is **not signed** with an Apple Developer certificate.  
> On first launch, right-click the app and select **Open**, then click **Open** in the dialog.

### Build from Source

```bash
# Requires Xcode Command Line Tools
git clone https://github.com/BlackMendrew/Breathe_tool.git
cd Breathe_tool
make
open BreatheTool.app
```

---

## Usage / 使用方式

| Action | How |
|--------|-----|
| Start / Pause breathing | Click the center of the window |
| Move the window | Drag anywhere on the window |
| Show / Hide the window | Click the 🫁 menu bar icon → "显示 / 隐藏" |
| Change inhale duration | Menu bar → "吸气" → select seconds |
| Change exhale duration | Menu bar → "呼气" → select seconds |
| Adjust opacity | Menu bar → transparency slider |
| Quit | Menu bar → "退出" |

### Keyboard Shortcuts / 快捷键

| Key | Action |
|-----|--------|
| Click window center | Start / Pause |
| `Space` (in menu) | Start / Pause |
| `B` (in menu) | Show / Hide window |

---

## Tech Stack / 技术栈

- **Swift 5.9+** / **SwiftUI** — application UI
- **AppKit** (`NSPanel`) — floating window with `canJoinAllSpaces` + `fullScreenAuxiliary`
- **Combine** — reactive state management
- **macOS 14+** — minimum deployment target

### Window Floating Strategy

The tool uses an `NSPanel` with:
```
.level = floatingWindow + 10
.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
```

This ensures visibility across all macOS Spaces, including fullscreen applications.

---

## License

MIT

---

*Made with ❤️ for better breathing.*
