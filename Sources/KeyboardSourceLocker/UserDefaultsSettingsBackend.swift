import Foundation

public final class UserDefaultsSettingsBackend: SettingsBackend {
    private let defaults: UserDefaults
    private let key: String

    public init(defaults: UserDefaults = .standard, key: String = "lockSettings") {
        self.defaults = defaults
        self.key = key
    }

    public func read() -> LockSettings? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(LockSettings.self, from: data)
    }

    public func write(_ settings: LockSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}
