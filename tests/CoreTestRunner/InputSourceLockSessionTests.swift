import KeyboardSourceLocker

@MainActor
enum InputSourceLockSessionTests {
    static func run() {
        print("InputSourceLockSession")
        restoresViaCatalogAfterDebounce()
        doesNotSelectWhenDisabled()
        listsInstalledSourcesFromCatalog()
        loadsPersistedSettingsOnStart()
        changingTargetPersistsAndRestoresNewOne()
        startIsIdempotent()
        stopClearsHandlerAndDisables()
        stopPreservesPersistedSettings()
        setLockedTargetWhileDisabledDoesNotSelect()
    }

    private static func restoresViaCatalogAfterDebounce() {
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("wechat")
        )
        let scheduler = ManualScheduler()
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: scheduler,
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setLockedTarget(InputSourceID("wechat"))
        session.setEnabled(true)

        catalog.simulateSystemSwitch(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(200))

        Expect.equal(catalog.selectedHistory, [InputSourceID("wechat")], "restores via catalog after debounce")
        Expect.equal(catalog.activeID, InputSourceID("wechat"), "active source ends on locked target")
    }

    private static func doesNotSelectWhenDisabled() {
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("wechat")
        )
        let scheduler = ManualScheduler()
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: scheduler,
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setLockedTarget(InputSourceID("wechat"))
        session.setEnabled(false)

        catalog.simulateSystemSwitch(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(200))

        Expect.true(catalog.selectedHistory.isEmpty, "does not select when lock disabled")
    }

    private static func listsInstalledSourcesFromCatalog() {
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("abc")
        )
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )

        Expect.equal(session.installedSources.count, 2, "lists installed sources from catalog")
        Expect.equal(session.installedSources.map(\.displayName), ["ABC", "微信输入法"], "preserves display names")
    }

    private static func loadsPersistedSettingsOnStart() {
        let backend = InMemorySettingsBackend(
            stored: LockSettings(isEnabled: true, lockedTargetID: InputSourceID("wechat"))
        )
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("abc")
        )
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: backend),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )

        session.start()

        Expect.equal(session.isEnabled, true, "loads persisted enabled state")
        Expect.equal(session.lockedTargetID, InputSourceID("wechat"), "loads persisted locked target")
    }

    private static func changingTargetPersistsAndRestoresNewOne() {
        let backend = InMemorySettingsBackend()
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("wechat")
        )
        let scheduler = ManualScheduler()
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: backend),
            scheduler: scheduler,
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setEnabled(true)
        session.setLockedTarget(InputSourceID("abc"))

        let reloaded = LockSettingsStore(backend: backend)
            .load(installedIDs: catalog.installedSources().map(\.id))
        Expect.equal(reloaded.lockedTargetID, InputSourceID("abc"), "persists changed locked target")

        catalog.simulateSystemSwitch(to: InputSourceID("wechat"))
        scheduler.advance(by: .milliseconds(200))
        Expect.equal(catalog.activeID, InputSourceID("abc"), "active source restored to new locked target")
        Expect.equal(catalog.selectedHistory.last, InputSourceID("abc"), "last catalog select is new locked target")
    }

    private static func startIsIdempotent() {
        let catalog = FakeInputSourceCatalog(
            sources: [InputSource(id: InputSourceID("abc"), displayName: "ABC")],
            activeID: InputSourceID("abc")
        )
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.start()
        Expect.equal(catalog.handlerSetCount, 1, "start is idempotent for change handler")
    }

    private static func stopClearsHandlerAndDisables() {
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("wechat")
        )
        let scheduler = ManualScheduler()
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: scheduler,
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setLockedTarget(InputSourceID("wechat"))
        session.setEnabled(true)
        session.stop()

        Expect.equal(session.isEnabled, false, "stop disables lock controller")
        Expect.true(catalog.handler == nil, "stop clears active-source handler")

        catalog.simulateSystemSwitch(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(200))
        Expect.true(catalog.selectedHistory.isEmpty, "no restores after stop")
    }

    private static func stopPreservesPersistedSettings() {
        let backend = InMemorySettingsBackend()
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("wechat")
        )
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: backend),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setLockedTarget(InputSourceID("wechat"))
        session.setEnabled(true)
        session.stop()

        let persisted = backend.read()
        Expect.equal(persisted?.isEnabled, true, "stop keeps persisted enabled state")
        Expect.equal(persisted?.lockedTargetID, InputSourceID("wechat"), "stop keeps persisted locked target")

        let resumed = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: backend),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )
        resumed.start()
        Expect.equal(resumed.isEnabled, true, "restart resumes persisted enabled state")
    }

    private static func setLockedTargetWhileDisabledDoesNotSelect() {
        let catalog = FakeInputSourceCatalog(
            sources: [
                InputSource(id: InputSourceID("abc"), displayName: "ABC"),
                InputSource(id: InputSourceID("wechat"), displayName: "微信输入法"),
            ],
            activeID: InputSourceID("abc")
        )
        let session = InputSourceLockSession(
            catalog: catalog,
            settingsStore: LockSettingsStore(backend: InMemorySettingsBackend()),
            scheduler: ManualScheduler(),
            debounceInterval: .milliseconds(200)
        )
        session.start()
        session.setEnabled(false)
        catalog.clearSelectedHistory()
        session.setLockedTarget(InputSourceID("wechat"))

        Expect.equal(session.lockedTargetID, InputSourceID("wechat"), "updates locked target while disabled")
        Expect.true(catalog.selectedHistory.isEmpty, "does not select target while disabled")
    }
}
