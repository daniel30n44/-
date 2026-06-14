# 架构设计 — 历史粘贴板

## 整体架构

```
┌──────────────────────────────────────────────────────┐
│                   HistoryClipboardApp                 │
│                  (@main SwiftUI App)                  │
│                                                      │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │ MenuBarExtra │  │ Window("main")│  │  Settings   │ │
│  │   (菜单栏)    │  │   (主窗口)     │  │  (设置窗口)  │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                 │                  │        │
│         └─────────────────┼──────────────────┘        │
│                           │                           │
│                    ┌──────▼──────┐                    │
│                    │  DataStore   │                    │
│                    │ @Observable  │                    │
│                    └──────┬──────┘                    │
│                           │                           │
│              ┌────────────┼────────────┐              │
│              │            │            │              │
│     ┌────────▼───┐ ┌─────▼──────┐ ┌──▼──────────┐   │
│     │ Clipboard  │ │  JSON +    │ │  Paste      │   │
│     │ Monitor    │ │  File I/O  │ │  Service    │   │
│     │ (Timer)    │ │            │ │  (CGEvent)  │   │
│     └────────────┘ └────────────┘ └─────────────┘   │
└──────────────────────────────────────────────────────┘
```

## 模块职责

### HistoryClipboardApp (入口)
- 初始化 DataStore 和 ClipboardMonitor
- 注册 MenuBarExtra、Window、Settings 三个 Scene
- 处理窗口打开逻辑

### ClipboardItem (模型)
- 定义剪贴板条目的数据结构
- 支持 Codable 持久化
- 计算属性：预览文本、过期判断

### DataStore (数据层)
- `@Published var items: [ClipboardItem]` — UI 绑定的数据源
- JSON 读写
- 图片文件管理
- CRUD 操作
- 过期清理
- 排序逻辑

### ClipboardMonitor (监听层)
- Timer 驱动，0.5s 轮询 NSPasteboard
- changeCount 变化检测
- 文字 / 图片内容读取
- 去重逻辑
- 回调 DataStore 进行存储

### PasteService (粘贴层)
- 写入 NSPasteboard
- CGEvent 模拟 Cmd+V
- 纯静态方法

### Views (视图层)
- **MenuBarView**: 菜单栏弹出面板，最近 5 条
- **MainWindowView**: 主窗口，完整列表 + 搜索
- **ClipboardCard**: 单条卡片组件
- **SearchBar**: 搜索输入框
- **SettingsView**: 设置界面

## 数据关系

```
ClipboardItem (1)
    ├── id: UUID (PK)
    ├── type: .text | .image
    ├── textContent: String?     ← 文字类型
    ├── imageFileName: String?   ← 图片类型 → images/<filename>.png
    ├── timestamp: Date
    ├── isPinned: Bool
    └── expiresAt: Date          ← timestamp + retentionDays (置顶 = distantFuture)
```
