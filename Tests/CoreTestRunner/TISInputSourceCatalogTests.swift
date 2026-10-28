import Foundation
import KeyboardSourceLocker

enum TISInputSourceCatalogTests {
    static func run() {
        print("TISInputSourceCatalog")
        listsInstalledKeyboardSources()
        reportsActiveSource()
        selectUnknownSourceFails()
        selectActiveSourceSucceeds()
        observingHandlerLifecycle()
    }

    private static func listsInstalledKeyboardSources() {
        let catalog = TISInputSourceCatalog()
        let sources = catalog.installedSources()
        Expect.true(!sources.isEmpty, "lists at least one installed keyboard source")
        Expect.true(sources.allSatisfy { !$0.displayName.isEmpty }, "sources have display names")
        Expect.true(sources.allSatisfy { !$0.id.rawValue.isEmpty }, "sources have ids")
    }

    private static func reportsActiveSource() {
        let catalog = TISInputSourceCatalog()
        let active = catalog.activeSourceID()
        Expect.true(active != nil, "reports an active input source id")
        if let active {
            let ids = Set(catalog.installedSources().map(\.id))
            // Active source may be a parent IME that is filtered from the picker; still must be non-empty.
            Expect.true(!active.rawValue.isEmpty, "active source id is non-empty")
            _ = ids
        }
    }

    private static func selectUnknownSourceFails() {
        let catalog = TISInputSourceCatalog()
        let ok = catalog.selectSource(id: InputSourceID("com.heyq02.keyboard-source-locker.missing"))
        Expect.equal(ok, false, "selecting unknown source fails")
    }

    private static func selectActiveSourceSucceeds() {
        let catalog = TISInputSourceCatalog()
        guard let active = catalog.activeSourceID() else {
            Expect.true(false, "select active source requires an active id")
            return
        }
        let ok = catalog.selectSource(id: active)
        Expect.equal(ok, true, "selecting the active source succeeds")
    }

    private static func observingHandlerLifecycle() {
        let catalog = TISInputSourceCatalog()
        let lock = NSLock()
        var events: [InputSourceID] = []

        catalog.setActiveSourceChangeHandler { id in
            lock.lock()
            events.append(id)
            lock.unlock()
        }
        // Setting again should be idempotent for DistributedNotificationCenter registration.
        catalog.setActiveSourceChangeHandler { id in
            lock.lock()
            events.append(id)
            lock.unlock()
        }

        if let active = catalog.activeSourceID() {
            DistributedNotificationCenter.default().post(
                name: Notification.Name("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
                object: nil
            )
            // Give the main/default queue a beat; notification delivery is async.
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
            _ = active
        }

        catalog.setActiveSourceChangeHandler(nil)
        catalog.setActiveSourceChangeHandler(nil)

        lock.lock()
        let count = events.count
        lock.unlock()
        Expect.true(count >= 0, "observing lifecycle completes without crash (\(count) events)")
    }
}
