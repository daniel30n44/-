import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataStore: DataStore
    @State private var selectedDays: Int
    @State private var launchAtLogin: Bool

    /// LaunchAgent plist 路径
    private static let launchAgentURL = URL(
        fileURLWithPath: NSHomeDirectory()
    ).appendingPathComponent("Library/LaunchAgents/com.historyclipboard.plist")

    init(dataStore: DataStore) {
        self.dataStore = dataStore
        _selectedDays = State(initialValue: dataStore.retentionDays)
        _launchAtLogin = State(initialValue: FileManager.default.fileExists(atPath: Self.launchAgentURL.path))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            Text("设置")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color(hex: "2C6E91"))
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // 保留天数
                    settingsSection(
                        icon: "clock.arrow.circlepath",
                        title: "历史保留时长",
                        description: "超过设定天数的记录会自动清理，置顶条目不受影响"
                    ) {
                        HStack(spacing: 12) {
                            ForEach([1, 3, 5], id: \.self) { days in
                                Button(action: {
                                    selectedDays = days
                                    dataStore.retentionDays = days
                                }) {
                                    Text("\(days) 天")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(selectedDays == days ? .white : Color(hex: "5BA4C9"))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    selectedDays == days
                                                        ? Color(hex: "5BA4C9")
                                                        : Color(hex: "E8F4F9")
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider()
                        .padding(.horizontal, 20)

                    // 开机自启
                    settingsSection(
                        icon: "power",
                        title: "开机自动启动",
                        description: "登录系统时自动运行历史粘贴板"
                    ) {
                        Toggle(isOn: $launchAtLogin) {
                            Text(launchAtLogin ? "已开启" : "已关闭")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    launchAtLogin ? Color(hex: "4CAF50") : .secondary
                                )
                        }
                        .toggleStyle(.switch)
                        .onChange(of: launchAtLogin) { oldValue, newValue in
                            toggleLaunchAtLogin(newValue)
                        }
                    }

                    Divider()
                        .padding(.horizontal, 20)

                    // 统计信息
                    settingsSection(
                        icon: "info.circle",
                        title: "存储信息",
                        description: nil
                    ) {
                        VStack(alignment: .leading, spacing: 6) {
                            InfoRow(label: "总记录数", value: "\(dataStore.items.count) 条")
                            InfoRow(label: "文字记录", value: "\(dataStore.items.filter { $0.type == .text }.count) 条")
                            InfoRow(label: "图片记录", value: "\(dataStore.items.filter { $0.type == .image }.count) 条")
                            InfoRow(label: "置顶条目", value: "\(dataStore.items.filter { $0.isPinned }.count) 条")
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .frame(width: 420, height: 480)
        .background(Color(hex: "F5F9FC"))
    }

    // MARK: - 设置区块

    private func settingsSection<Content: View>(
        icon: String,
        title: String,
        description: String?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "5BA4C9"))
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)

            if let description = description {
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }

            content()
                .padding(.horizontal, 20)
        }
    }

    // MARK: - 开机自启

    private func toggleLaunchAtLogin(_ enabled: Bool) {
        if enabled {
            createLaunchAgent()
        } else {
            removeLaunchAgent()
        }
        // 立即刷新状态
        launchAtLogin = FileManager.default.fileExists(atPath: Self.launchAgentURL.path)
    }

    /// 创建 LaunchAgent plist 并加载
    private func createLaunchAgent() {
        let appPath = Bundle.main.bundlePath

        let plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>Label</key>
            <string>com.historyclipboard</string>
            <key>ProgramArguments</key>
            <array>
                <string>/usr/bin/open</string>
                <string>\(appPath)</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>KeepAlive</key>
            <false/>
        </dict>
        </plist>
        """

        do {
            try plistContent.write(to: Self.launchAgentURL, atomically: true, encoding: .utf8)
            // 注册到 launchd
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["load", Self.launchAgentURL.path]
            try task.run()
            task.waitUntilExit()
        } catch {
            print("创建开机自启失败: \(error.localizedDescription)")
        }
    }

    /// 移除 LaunchAgent plist
    private func removeLaunchAgent() {
        // 先从 launchd 卸载
        let unloadTask = Process()
        unloadTask.launchPath = "/bin/launchctl"
        unloadTask.arguments = ["unload", Self.launchAgentURL.path]
        try? unloadTask.run()
        unloadTask.waitUntilExit()

        // 再删除 plist 文件
        try? FileManager.default.removeItem(at: Self.launchAgentURL)
    }
}

// MARK: - 信息行

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}
