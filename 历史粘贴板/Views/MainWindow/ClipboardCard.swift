import SwiftUI

struct ClipboardCard: View {
    let item: ClipboardItem
    let isSelected: Bool
    let onTap: () -> Void
    let onTogglePin: () -> Void
    let onDelete: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                // 左侧：内容区
                VStack(alignment: .leading, spacing: 8) {
                    // 置顶标签
                    if item.isPinned {
                        HStack(spacing: 4) {
                            Image(systemName: "pin.fill")
                                .font(.system(size: 10))
                            Text("置顶")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color(hex: "5BA4C9"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "D6EEF8"))
                        .clipShape(Capsule())
                    }

                    // 内容
                    if item.type == .image, let fileName = item.imageFileName {
                        imageThumbnail(fileName: fileName)
                    } else {
                        Text(item.previewText)
                            .font(.system(size: 14))
                            .lineLimit(5)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                    }

                    // 时间
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(item.timestamp.relativeDescription)
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }

                Spacer()

                // 右侧：操作按钮
                if isHovered {
                    VStack(spacing: 4) {
                        // 置顶按钮
                        pinButton

                        // 删除按钮
                        deleteButton
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(
                        color: isSelected
                            ? Color(hex: "7EC8E3").opacity(0.3)
                            : Color.black.opacity(0.05),
                        radius: isSelected ? 8 : 3,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                            ? Color(hex: "7EC8E3")
                            : Color(hex: "D6EEF8").opacity(isHovered ? 0.8 : 0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    // MARK: - 图片缩略图

    private func imageThumbnail(fileName: String) -> some View {
        let imagesDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        .appendingPathComponent("HistoryClipboard/images")
        let fileURL = imagesDir.appendingPathComponent(fileName)

        return Group {
            if let nsImage = NSImage(contentsOf: fileURL) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 180, maxHeight: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                HStack {
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.secondary)
                    Text("图片已丢失")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 60)
            }
        }
    }

    // MARK: - 操作按钮

    private var pinButton: some View {
        Button(action: onTogglePin) {
            Image(systemName: item.isPinned ? "pin.slash" : "pin")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "5BA4C9"))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color(hex: "E8F4F9"))
                )
        }
        .buttonStyle(.plain)
        .help(item.isPinned ? "取消置顶" : "置顶")
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "trash")
                .font(.system(size: 13))
                .foregroundColor(.red.opacity(0.7))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.red.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
        .help("删除")
    }
}
