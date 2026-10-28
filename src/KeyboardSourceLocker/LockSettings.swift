public struct LockSettings: Equatable, Sendable, Codable {
    public var isEnabled: Bool
    public var lockedTargetID: InputSourceID?

    public init(isEnabled: Bool = false, lockedTargetID: InputSourceID? = nil) {
        self.isEnabled = isEnabled
        self.lockedTargetID = lockedTargetID
    }
}

public protocol SettingsBackend: AnyObject {
    func read() -> LockSettings?
    func write(_ settings: LockSettings)
}

public final class InMemorySettingsBackend: SettingsBackend {
    private var stored: LockSettings?

    public init(stored: LockSettings? = nil) {
        self.stored = stored
    }

    public func read() -> LockSettings? { stored }

    public func write(_ settings: LockSettings) {
        stored = settings
    }
}

public final class LockSettingsStore {
    private let backend: any SettingsBackend

    public init(backend: any SettingsBackend) {
        self.backend = backend
    }

    public func save(_ settings: LockSettings) {
        backend.write(settings)
    }

    public func load(installedIDs: [InputSourceID]) -> LockSettings {
        guard var settings = backend.read() else {
            return LockSettings()
        }

        if let target = settings.lockedTargetID, !installedIDs.contains(target) {
            settings.isEnabled = false
            settings.lockedTargetID = nil
        }

        return settings
    }
}
