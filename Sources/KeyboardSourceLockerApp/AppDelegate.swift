import AppKit
import KeyboardSourceLocker

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var session: InputSourceLockSession!

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

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item
        if let button = item.button {
            button.image = NSImage(
                systemSymbolName: session.isEnabled ? "lock.fill" : "lock.open",
                accessibilityDescription: "Keyboard Source Locker"
            )
        }
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
            keyEquivalent: ""
        )
        lockItem.state = session.isEnabled ? .on : .off
        lockItem.target = self
        menu.addItem(lockItem)

        let targetName = session.installedSources
            .first { $0.id == session.lockedTargetID }?
            .displayName ?? "(none)"
        menu.addItem(NSMenuItem(
            title: "Locked to: \(targetName)",
            action: nil,
            keyEquivalent: ""
        ))

        menu.addItem(.separator())

        let selectMenu = NSMenu()
        for source in session.installedSources {
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
        let selectRoot = NSMenuItem(title: "Select Input Source", action: nil, keyEquivalent: "")
        selectRoot.submenu = selectMenu
        menu.addItem(selectRoot)

        menu.addItem(.separator())

        let quit = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
        statusItem?.button?.image = NSImage(
            systemSymbolName: session.isEnabled ? "lock.fill" : "lock.open",
            accessibilityDescription: "Keyboard Source Locker"
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

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
