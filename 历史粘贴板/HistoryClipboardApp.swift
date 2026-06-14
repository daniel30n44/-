import SwiftUI

@main
struct HistoryClipboardApp: App {
    @StateObject private var dataStore = DataStore()
    @StateObject private var clipboardMonitor: ClipboardMonitor

    init() {
        let store = DataStore()
        _dataStore = StateObject(wrappedValue: store)
        let monitor = ClipboardMonitor(dataStore: store)
        _clipboardMonitor = StateObject(wrappedValue: monitor)
        // 应用启动即开始监听剪贴板
        monitor.startMonitoring()
        print("📋 历史粘贴板已启动，条目数: \(store.items.count)")
    }

    var body: some Scene {
        // 菜单栏
        MenuBarExtra {
            MenuBarView(dataStore: dataStore, onOpenMainWindow: openMainWindow)
        } label: {
            Image(systemName: "clipboard")
                .font(.system(size: 14, weight: .medium))
        }
        .menuBarExtraStyle(.window)

        // 主窗口
        Window("历史粘贴板", id: "main") {
            MainWindowView(dataStore: dataStore)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 600)

        // 设置窗口
        Settings {
            SettingsView(dataStore: dataStore)
        }
        .windowResizability(.contentSize)
    }

    // MARK: - 打开主窗口

    func openMainWindow() {
        // 关闭菜单栏弹出面板
        NSApp.sendAction(#selector(NSMenu.cancelTracking), to: nil, from: nil)

        // 激活应用（确保窗口置前）
        NSApp.activate(ignoringOtherApps: true)

        // 查找并打开主窗口
        for window in NSApp.windows {
            if window.identifier?.rawValue == "main" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }
}
