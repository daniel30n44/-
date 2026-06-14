import SwiftUI

// MARK: - 菜单栏弹出面板

struct MenuBarView: View {
    @ObservedObject var dataStore: DataStore
    let onOpenMainWindow: () -> Void

    @State private var searchText: String = ""
    @State private var hoveredItemId: UUID? = nil

    /// 根据搜索文本过滤后的条目
    private var filteredItems: [ClipboardItem] {
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return Array(dataStore.items.prefix(20))
        }
        return dataStore.items.filter { item in
            if item.type == .text {
                return item.textContent?.localizedCaseInsensitiveContains(trimmed) ?? false
            }
            return false
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: 顶部标题栏
            headerView

            // MARK: 搜索栏
            SearchBar(text: $searchText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)

            // MARK: 分割线
            separator

            // MARK: 内容区
            if filteredItems.isEmpty {
                emptyState
            } else {
                itemsList
            }

            // MARK: 底部分割线
            separator

            // MARK: 底部状态栏
            footerView
        }
        .frame(width: 360)
        .background(Color(hex: "F5F9FC"))
    }

    // MARK: - 顶部标题栏

    private var headerView: some View {
        HStack(spacing: 6) {
            Image(systemName: "clipboard")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "7EC8E3"))

            Text("历史粘贴板")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "2C6E91"))

            Spacer()

            Button(action: onOpenMainWindow) {
                HStack(spacing: 4) {
                    Text("完整窗口")
                        .font(.system(size: 11))
                    Image(systemName: "arrow.up.left.app")
                        .font(.system(size: 11))
                }
                .foregroundColor(Color(hex: "5BA4C9"))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(hex: "E8F4F9"))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - 分割线

    private var separator: some View {
        Rectangle()
            .fill(Color(hex: "D6EEF8"))
            .frame(height: 1)
    }

    // MARK: - 空状态

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(Color(hex: "A8D8EA"))

            Text(searchText.isEmpty ? "暂无复制记录" : "无匹配结果")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "5BA4C9"))

            Text(searchText.isEmpty
                ? "Command + C 复制一段文字，自动出现在这里"
                : "尝试其他关键词搜索")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "A8D8EA"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - 条目列表

    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: 6) {
                ForEach(filteredItems) { item in
                    MenuBarItemRow(
                        item: item,
                        isHovered: hoveredItemId == item.id,
                        onPaste: { PasteService.paste(item) },
                        onHover: { hovering in
                            hoveredItemId = hovering ? item.id : nil
                        }
                    )
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
        }
        .frame(minHeight: 240, maxHeight: 380)
    }

    // MARK: - 底部状态栏

    private var footerView: some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "A8D8EA"))
                Text("\(dataStore.retentionDays)天")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "A8D8EA"))
            }

            Spacer()

            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("找到 \(filteredItems.count) 条")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "5BA4C9"))
                Spacer()
            }

            Text("共 \(dataStore.items.count) 条记录")
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "A8D8EA"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(hex: "E8F4F9").opacity(0.4))
    }
}

// MARK: - 单条记录行

struct MenuBarItemRow: View {
    let item: ClipboardItem
    let isHovered: Bool
    let onPaste: () -> Void
    let onHover: (Bool) -> Void

    var body: some View {
        Button(action: onPaste) {
            HStack(spacing: 10) {
                // 类型图标
                typeIcon
                    .frame(width: 28, height: 28)

                // 内容
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.previewText)
                        .font(.system(size: 13))
                        .lineLimit(2)
                        .foregroundColor(.primary)

                    Text(item.timestamp.relativeDescription)
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "A8D8EA"))
                }

                Spacer(minLength: 8)

                // 置顶标记
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "7EC8E3"))
                }

                // 粘贴快捷箭头
                if isHovered {
                    Image(systemName: "arrow.turn.down.left")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "5BA4C9"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(
                        color: isHovered
                            ? Color.black.opacity(0.08)
                            : Color.black.opacity(0.03),
                        radius: isHovered ? 4 : 2,
                        x: 0,
                        y: isHovered ? 2 : 1
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isHovered ? Color(hex: "7EC8E3") : Color(hex: "D6EEF8"),
                        lineWidth: isHovered ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover(perform: onHover)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }

    // MARK: - 类型图标

    @ViewBuilder
    private var typeIcon: some View {
        if item.type == .image {
            if let fileName = item.imageFileName {
                let imagesDir = FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first!
                .appendingPathComponent("HistoryClipboard/images")
                let fileURL = imagesDir.appendingPathComponent(fileName)

                if let nsImage = NSImage(contentsOf: fileURL) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    iconPlaceholder(systemName: "photo")
                }
            } else {
                iconPlaceholder(systemName: "photo")
            }
        } else {
            iconPlaceholder(systemName: "doc.text")
        }
    }

    private func iconPlaceholder(systemName: String) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: "E8F4F9"))
            .frame(width: 28, height: 28)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "7EC8E3"))
            )
    }
}
