import SwiftUI

struct MainWindowView: View {
    @ObservedObject var dataStore: DataStore
    @State private var searchText: String = ""
    @State private var selectedItem: ClipboardItem?
    @State private var showDeleteAlert = false
    @State private var itemToDelete: ClipboardItem?

    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            headerView

            Divider()

            // 搜索栏
            SearchBar(text: $searchText)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            Divider()

            // 内容区
            if filteredItems.isEmpty {
                emptyStateView
            } else {
                listView
            }
        }
        .frame(minWidth: 420, minHeight: 500)
        .background(Color(hex: "F5F9FC"))
        .alert("确认删除", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation {
                        dataStore.delete(item)
                    }
                }
            }
        } message: {
            Text("确定要删除这条记录吗？此操作不可撤销。")
        }
    }

    // MARK: - 顶部标题栏

    private var headerView: some View {
        HStack {
            Text("📋 历史粘贴板")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "2C6E91"))

            Spacer()

            // 设置按钮
            if #available(macOS 14.0, *) {
                SettingsLink {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16))
                }
                .buttonStyle(.borderless)
            } else {
                Button(action: {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16))
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - 空状态

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(Color(hex: "A8D8EA").opacity(0.6))
            Text(searchText.isEmpty ? "暂无复制记录" : "未找到匹配结果")
                .font(.title3)
                .foregroundColor(.secondary)
            Text(searchText.isEmpty ? "试试复制一段文字或图片，它会自动出现在这里" : "换个关键词试试")
                .font(.body)
                .foregroundColor(.secondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 列表视图

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredItems) { item in
                    ClipboardCard(
                        item: item,
                        isSelected: selectedItem?.id == item.id,
                        onTap: {
                            selectedItem = item
                            PasteService.paste(item)
                        },
                        onTogglePin: {
                            withAnimation {
                                dataStore.togglePin(item)
                            }
                        },
                        onDelete: {
                            itemToDelete = item
                            showDeleteAlert = true
                        }
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    /// 过滤后的条目
    private var filteredItems: [ClipboardItem] {
        let sorted = dataStore.items.sorted { a, b in
            if a.isPinned != b.isPinned {
                return a.isPinned && !b.isPinned
            }
            return a.timestamp > b.timestamp
        }

        if searchText.isEmpty {
            return sorted
        }

        return sorted.filter { item in
            if item.type == .text {
                return item.textContent?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            return false
        }
    }
}
