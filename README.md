# 📋 ClipboardManager

A macOS menu bar clipboard history manager — auto-records text and images you copy.<br>
macOS 菜单栏剪贴板历史管理工具，自动记录文字和图片复制内容。

---

## Features · 功能

| | English | 中文 |
|------|------|------|
| 📋 | **Auto-record**: Monitors clipboard in background, auto-saves text & images | **自动记录**：后台监听剪贴板，文字和图片自动保存 |
| 📌 | **Quick paste**: Click a record to copy, then Cmd+V to paste anywhere | **快速粘贴**：点击历史记录即可复制，Cmd+V 粘贴到任意位置 |
| 🔍 | **Keyword search**: Type to filter history instantly | **关键词搜索**：输入关键词快速定位历史内容 |
| 📍 | **Pin**: Important items stay forever, immune to auto-cleanup | **置顶**：重要内容置顶，不受过期清理影响 |
| ⏳ | **Retention**: Auto-clean after 1/3/5 days to save space | **保留时长**：1/3/5 天自动清理，节省空间 |
| 🌐 | **6 Languages**: English, 中文, 日本語, 한국어, Español, Português | **六种语言**：英文、中文、日文、韩文、西班牙文、葡萄牙文 |
| 🍃 | **Menu bar only**: Stays in menu bar, no Dock icon, low footprint | **菜单栏运行**：安静驻留在菜单栏，无 Dock 图标，低打扰 |

## Requirements · 系统要求

- macOS 14.0+
- Apple Silicon / Intel (Universal)

## Installation · 安装

```bash
# 1. Clone the repo / 克隆仓库
git clone https://github.com/daniel30n44/ClipboardManager.git
cd ClipboardManager

# 2. Open in Xcode / Xcode 打开项目
open ClipboardManager.xcodeproj

# 3. Build & run (Cmd+R) / 编译运行
```

> On first run a 📋 icon appears in the menu bar. To run independently of Xcode, copy the built `.app` to `~/Applications/` and enable Launch at Login in Settings.<br>
> 首次运行菜单栏会出现 📋 图标。如需独立于 Xcode 运行，将编译的 .app 复制到 `~/Applications/`，在设置中开启开机自启即可。

## Tech Stack · 技术栈

| Item · 项目 | Tech · 技术 |
|-------------|-------------|
| Language · 语言 | Swift 6 |
| UI | SwiftUI |
| Storage · 存储 | JSON + local file system |
| Image format · 图片格式 | PNG |
| Min OS · 最低系统 | macOS 14.0 |

## Project Structure · 项目结构

```
ClipboardManager/
├── Models/           # Data models · 数据模型
│   └── ClipboardItem.swift
├── Services/         # Business logic · 业务逻辑
│   ├── ClipboardMonitor.swift   # Clipboard polling · 剪贴板监听
│   ├── DataStore.swift          # Persistence · 数据持久化
│   └── PasteService.swift       # Paste operations · 粘贴服务
├── Views/            # UI · 界面
│   ├── MenuBar/      # Menu bar popup · 菜单栏面板
│   ├── MainWindow/   # Main window · 主窗口
│   └── Settings/     # Settings · 设置
├── Utils/            # Utilities · 工具扩展
│   ├── Color+Hex.swift
│   ├── DateFormatter+Extensions.swift
│   └── LocalizationService.swift  # 6-language support · 六语言支持
└── docs/             # Documentation · 项目文档
```

## Screenshots · 截图

| Menu Bar · 菜单栏 | Main Window · 主窗口 |
|:---:|:---:|
| Click the 📋 icon · 点击菜单栏图标 | Search + full list · 搜索 + 完整列表 |

## License · 许可证

MIT License
