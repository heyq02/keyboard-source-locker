import KeyboardSourceLocker

enum LockSettingsStoreTests {
    static func run() {
        print("LockSettingsStore")
        roundTripsEnabledAndTarget()
        missingTargetDisablesLockWithoutSubstituting()
        missingTargetClearsLockedIDWhenAbsent()
    }

    private static func roundTripsEnabledAndTarget() {
        let memory = InMemorySettingsBackend()
        let store = LockSettingsStore(backend: memory)

        store.save(LockSettings(isEnabled: true, lockedTargetID: InputSourceID("wechat")))
        let loaded = store.load(installedIDs: [InputSourceID("abc"), InputSourceID("wechat")])

        Expect.equal(loaded.isEnabled, true, "persists lock enabled")
        Expect.equal(loaded.lockedTargetID, InputSourceID("wechat"), "persists locked target id")
    }

    private static func missingTargetDisablesLockWithoutSubstituting() {
        let memory = InMemorySettingsBackend()
        let store = LockSettingsStore(backend: memory)
        store.save(LockSettings(isEnabled: true, lockedTargetID: InputSourceID("wechat")))

        let loaded = store.load(installedIDs: [InputSourceID("abc")])

        Expect.equal(loaded.isEnabled, false, "missing target disables lock")
        Expect.equal(loaded.lockedTargetID, nil as InputSourceID?, "does not substitute another source")
    }

    private static func missingTargetClearsLockedIDWhenAbsent() {
        let memory = InMemorySettingsBackend()
        let store = LockSettingsStore(backend: memory)
        store.save(LockSettings(isEnabled: false, lockedTargetID: InputSourceID("gone")))

        let loaded = store.load(installedIDs: [InputSourceID("abc")])

        Expect.equal(loaded.isEnabled, false, "stays disabled when target missing")
        Expect.equal(loaded.lockedTargetID, nil as InputSourceID?, "clears missing locked target id")
    }
}
