import KeyboardSourceLocker

enum InputSourceLockSessionTests {
    static func run() {
        print("InputSourceLockSession")
        restoresViaCatalogAfterDebounce()
        doesNotSelectWhenDisabled()
        listsInstalledSourcesFromCatalog()
        loadsPersistedSettingsOnStart()
        changingTargetPersistsAndRestoresNewOne()
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
}
