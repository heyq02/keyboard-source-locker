import Foundation
import KeyboardSourceLocker

enum UserDefaultsSettingsBackendTests {
    static func run() {
        print("UserDefaultsSettingsBackend")
        returnsNilWhenMissing()
        roundTripsSettings()
        overwritesPreviousValue()
    }

    private static func suiteDefaults() -> (UserDefaults, String) {
        let name = "KeyboardSourceLocker.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return (defaults, name)
    }

    private static func returnsNilWhenMissing() {
        let (defaults, name) = suiteDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        let backend = UserDefaultsSettingsBackend(defaults: defaults, key: "lockSettings")
        Expect.true(backend.read() == nil, "returns nil when key missing")
    }

    private static func roundTripsSettings() {
        let (defaults, name) = suiteDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        let backend = UserDefaultsSettingsBackend(defaults: defaults, key: "lockSettings")
        let settings = LockSettings(isEnabled: true, lockedTargetID: InputSourceID("wechat"))
        backend.write(settings)

        Expect.equal(backend.read()?.isEnabled, true, "reads back enabled flag")
        Expect.equal(backend.read()?.lockedTargetID, InputSourceID("wechat"), "reads back locked target")
    }

    private static func overwritesPreviousValue() {
        let (defaults, name) = suiteDefaults()
        defer { defaults.removePersistentDomain(forName: name) }

        let backend = UserDefaultsSettingsBackend(defaults: defaults, key: "lockSettings")
        backend.write(LockSettings(isEnabled: true, lockedTargetID: InputSourceID("wechat")))
        backend.write(LockSettings(isEnabled: false, lockedTargetID: nil))

        Expect.equal(backend.read()?.isEnabled, false, "overwrites enabled flag")
        Expect.equal(backend.read()?.lockedTargetID, nil as InputSourceID?, "overwrites locked target to nil")
    }
}
