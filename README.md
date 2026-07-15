# 🫁 BreatheTool — 呼吸练习悬浮工具

macOS 悬浮置顶的呼吸法练习工具。单色呼吸灯，极简设计，全屏可用。

<p align="center">
  <img src="screenshots/circle_idle.png" width="180" alt="圆圈模式" />
  <img src="screenshots/circle_running.png" width="180" alt="呼吸中" />
  <img src="screenshots/compact.png" width="200" alt="紧凑模式" />
</p>

---

## 功能

- 📌 **始终置顶** — 悬浮在所有窗口上方，包括全屏应用
- 👆 **点击即用** — 点击窗口任意位置开始/暂停
- ⏱️ **可调节节奏** — 吸气、呼气时长独立设置（2—10 秒），支持屏息（0—3 秒）
- 🌊 **单色呼吸灯** — 柔青绿色随时间明暗变化，吸气渐亮、呼气渐暗，过渡自然
- 🔍 **可调透明度** — 菜单栏滑块，20%—100% 自由调节
- 🪟 **双模式** — 圆圈模式（含倒计时）/ 紧凑模式（进度条+标签）
- 📊 **菜单栏图标** — 所有设置通过菜单栏 🫁 图标完成
- 🖥️ **跨空间显示** — 即使切换到全屏 App 也保持可见
- 💾 **设置持久化** — 所有参数自动保存，重启恢复

---

## 截图

| 圆圈模式（空闲） | 圆圈模式（呼吸中） | 紧凑模式 |
|:---:|:---:|:---:|
| ![空闲](screenshots/circle_idle.png) | ![呼吸](screenshots/circle_running.png) | ![紧凑](screenshots/compact.png) |

---

## 安装

### 下载 DMG

1. 打开 [Releases](https://github.com/BlackMendrew/Breathe_tool/releases) 页面
2. 下载最新的 `BreatheTool.dmg`
3. 打开 DMG，将 `BreatheTool.app` 拖入 `Applications` 文件夹
4. 首次打开若被阻止，前往 **系统设置 → 隐私与安全性** 中允许运行

### 从源码编译

```bash
git clone https://github.com/BlackMendrew/Breathe_tool.git
cd Breathe_tool
make
open BreatheTool.app
```

---

## 使用方式

| 操作 | 方法 |
|------|------|
| 开始 / 暂停 | 点击窗口任意位置 |
| 移动窗口 | 拖拽窗口 |
| 显示 / 隐藏 | 菜单栏 🫁 →「显示 / 隐藏」 |
| 吸气时长 | 菜单栏 →「吸气」→ 2—10 秒 |
| 呼气时长 | 菜单栏 →「呼气」→ 2—10 秒 |
| 屏息时长 | 菜单栏 →「屏息」→ 0—3 秒 |
| 紧凑模式 | 菜单栏 → 勾选「紧凑模式」 |
| 透明度 | 菜单栏 → 滑动滑块 |
| 退出 | 菜单栏 →「退出」 |

---

## 技术实现

- **Swift 5.9+ / SwiftUI** — 界面渲染
- **AppKit** (`NSPanel`) — `canJoinAllSpaces` + `fullScreenAuxiliary` 跨空间悬浮
- **Combine** — 响应式状态管理
- **macOS 14+** — 最低部署版本

---

## 许可证

MIT
