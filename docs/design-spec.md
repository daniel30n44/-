# 设计规范 — 历史粘贴板

## 设计原则

- **简洁直观**：减少视觉噪音，功能一目了然
- **低打扰**：菜单栏图标小巧，不占用 Dock 空间
- **快速操作**：最少点击完成粘贴

## 色彩系统

| 用途 | 色值 | Hex |
|------|------|-----|
| 主色调（浅蓝） | ![#A8D8EA](https://via.placeholder.com/15/A8D8EA/A8D8EA) | `#A8D8EA` |
| 主色调（中蓝） | ![#7EC8E3](https://via.placeholder.com/15/7EC8E3/7EC8E3) | `#7EC8E3` |
| 主色调（深蓝） | ![#5BA4C9](https://via.placeholder.com/15/5BA4C9/5BA4C9) | `#5BA4C9` |
| 标题色 | ![#2C6E91](https://via.placeholder.com/15/2C6E91/2C6E91) | `#2C6E91` |
| 置顶标签背景 | ![#D6EEF8](https://via.placeholder.com/15/D6EEF8/D6EEF8) | `#D6EEF8` |
| 按钮背景 | ![#E8F4F9](https://via.placeholder.com/15/E8F4F9/E8F4F9) | `#E8F4F9` |
| 页面背景 | ![#F5F9FC](https://via.placeholder.com/15/F5F9FC/F5F9FC) | `#F5F9FC` |
| 卡片背景 | 白色 | `#FFFFFF` |
| 绿色（开启状态） | ![#4CAF50](https://via.placeholder.com/15/4CAF50/4CAF50) | `#4CAF50` |

## 排版

- **字体**：系统默认 San Francisco
- **标题**: `.title2` / `.headline`
- **正文**: `.system(size: 14)` / `.system(size: 13)`
- **辅助文字**: `.caption` / `.system(size: 11)`
- **等宽/代码**: 不使用

## 组件规范

### 卡片 (ClipboardCard)

| 属性 | 值 |
|------|-----|
| 圆角 | 12px |
| 背景 | 白色 |
| 阴影 | `black.opacity(0.05)`, radius: 3, y: 2 |
| 选中边框 | `#7EC8E3`, 2px |
| 默认边框 | `#D6EEF8`, 1px |
| 内边距 | 14px |

### 按钮 (操作按钮)

| 属性 | 值 |
|------|-----|
| 形状 | 圆形 (28x28) |
| 背景 | `#E8F4F9` (蓝色按钮) / `red.opacity(0.1)` (删除) |
| 图标 | SF Symbols |

### 搜索框 (SearchBar)

| 属性 | 值 |
|------|-----|
| 圆角 | 10px |
| 背景 | 白色 |
| 聚焦边框 | `#7EC8E3` 1.5px |
| 默认边框 | `#D6EEF8` 1px |

### 设置按钮 (天数选择)

| 状态 | 背景 | 文字色 |
|------|------|--------|
| 选中 | `#5BA4C9` solid | 白色 |
| 未选中 | `#E8F4F9` | `#5BA4C9` |
| 圆角 | 8px | |

## 窗口规范

| 窗口 | 最小尺寸 |
|------|----------|
| 菜单栏面板 | 320 x auto (最大 360 列表区) |
| 主窗口 | 420 x 500 |
| 设置窗口 | 420 x 480 |

## 图标

- 所有图标使用 **SF Symbols**，无需额外资源
- 菜单栏：`clipboard`
- 文字条目：`doc.text`
- 图片条目：`photo`
- 置顶：`pin.fill` / `pin.slash`
- 删除：`trash`
- 搜索：`magnifyingglass`
- 设置：`gearshape`
- 时钟：`clock`
- 展开：`rectangle.expand.vertical`
