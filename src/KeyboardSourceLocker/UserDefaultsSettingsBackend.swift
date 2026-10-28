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
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: key)
        } catch {
            // Keep the previous value rather than persisting a partial state.
            NSLog("KeyboardSourceLocker: failed to encode lock settings: \(error)")
        }
    }
}
