import AppKit
import KeyboardSourceLocker

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let projectURL = URL(string: "https://github.com/heyq02/keyboard-source-locker")!

    private var statusItem: NSStatusItem?
    private var session: InputSourceLockSession!
    private var launchAtLogin: LaunchAtLoginController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let catalog = TISInputSourceCatalog()
        let store = LockSettingsStore(backend: UserDefaultsSettingsBackend())
        session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: store,
            scheduler: DispatchQueueDebounceScheduler(queue: .main),
            debounceInterval: .milliseconds(200)
        )
        session.start()
        launchAtLogin = LaunchAtLoginController(service: SMAppServiceLaunchAtLogin())

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item
        item.button?.toolTip = "Keyboard Source Locker"
        updateStatusIcon()
        rebuildMenu()
    }

    func applicationWillTerminate(_ notification: Notification) {
        session.stop()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let lockTitle = session.isEnabled ? "Lock: On" : "Lock: Off"
        let lockItem = NSMenuItem(
            title: lockTitle,
            action: #selector(toggleLock),
            keyEquivalent: "l"
        )
        lockItem.state = session.isEnabled ? .on : .off
        lockItem.target = self
        menu.addItem(lockItem)

        let targetName = session.installedSources
            .first { $0.id == session.lockedTargetID }?
            .displayName ?? "(none)"
        let lockedItem = NSMenuItem(
            title: "Locked to: \(targetName)",
            action: nil,
            keyEquivalent: ""
        )
        lockedItem.isEnabled = false
        menu.addItem(lockedItem)

        menu.addItem(.separator())

        let selectMenu = NSMenu()
        let sources = session.installedSources
        if sources.isEmpty {
            let empty = NSMenuItem(title: "No selectable sources", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            selectMenu.addItem(empty)
        } else {
            for source in sources {
                let item = NSMenuItem(
                    title: source.displayName,
                    action: #selector(selectTarget(_:)),
                    keyEquivalent: ""
                )
                item.representedObject = source.id.rawValue
                item.state = source.id == session.lockedTargetID ? .on : .off
                item.target = self
                selectMenu.addItem(item)
            }
        }
        let selectRoot = NSMenuItem(title: "Select Input Source", action: nil, keyEquivalent: "")
        selectRoot.submenu = selectMenu
        menu.addItem(selectRoot)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.state = launchAtLogin.isEnabled ? .on : .off
        launchItem.target = self
        menu.addItem(launchItem)

        let versionItem = NSMenuItem(
            title: AppVersion.currentMenuTitle(),
            action: nil,
            keyEquivalent: ""
        )
        versionItem.isEnabled = false
        menu.addItem(versionItem)

        let about = NSMenuItem(
            title: "About Keyboard Source Locker",
            action: #selector(openAbout),
            keyEquivalent: ""
        )
        about.target = self
        menu.addItem(about)

        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
        updateStatusIcon()
    }

    private func updateStatusIcon() {
        statusItem?.button?.image = NSImage(
            systemSymbolName: session.isEnabled ? "lock.fill" : "lock.open",
            accessibilityDescription: session.isEnabled
                ? "Keyboard Source Locker — locked"
                : "Keyboard Source Locker — unlocked"
        )
    }

    @objc private func toggleLock() {
        session.setEnabled(!session.isEnabled)
        rebuildMenu()
    }

    @objc private func selectTarget(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String else { return }
        session.setLockedTarget(InputSourceID(raw))
        rebuildMenu()
    }

    @objc private func toggleLaunchAtLogin() {
        let desired = !launchAtLogin.isEnabled
        if !launchAtLogin.setEnabled(desired) {
            let message = launchAtLogin.lastErrorDescription
                ?? "Could not update Launch at Login."
            let alert = NSAlert()
            alert.messageText = "Launch at Login"
            alert.informativeText = message
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
        rebuildMenu()
    }

    @objc private func openAbout() {
        NSWorkspace.shared.open(Self.projectURL)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
