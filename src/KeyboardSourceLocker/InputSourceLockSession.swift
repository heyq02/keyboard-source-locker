/// App-facing wiring for the lock. Main-actor isolated: the catalog, settings store,
/// and scheduler are all expected to be driven from the main thread.
@MainActor
public final class InputSourceLockSession {
    private let catalog: any InputSourceCatalog
    private let settingsStore: LockSettingsStore
    private let controller: InputSourceLockController
    private var started = false

    public var isEnabled: Bool { controller.isEnabled }
    public var lockedTargetID: InputSourceID? { controller.lockedTargetID }
    public var installedSources: [InputSource] { catalog.installedSources() }

    public init(
        catalog: any InputSourceCatalog,
        settingsStore: LockSettingsStore,
        scheduler: any DebounceScheduler,
        debounceInterval: Duration = .milliseconds(200)
    ) {
        self.catalog = catalog
        self.settingsStore = settingsStore
        self.controller = InputSourceLockController(
            debounceInterval: debounceInterval,
            scheduler: scheduler,
            onRestore: { id in
                _ = catalog.selectSource(id: id)
            }
        )
    }

    public func start() {
        guard !started else { return }
        started = true

        let installedIDs = catalog.installedSources().map(\.id)
        let settings = settingsStore.load(installedIDs: installedIDs)
        controller.setLockedTarget(settings.lockedTargetID)
        controller.setEnabled(settings.isEnabled)

        catalog.setActiveSourceChangeHandler { [weak self] id in
            self?.controller.activeSourceDidChange(to: id)
        }
    }

    /// Stops observing without touching persisted settings, so a later `start()`
    /// resumes the user's previous lock state.
    public func stop() {
        catalog.setActiveSourceChangeHandler(nil)
        controller.setEnabled(false)
        started = false
    }

    public func setEnabled(_ enabled: Bool) {
        controller.setEnabled(enabled)
        persist()
    }

    public func setLockedTarget(_ id: InputSourceID?) {
        controller.setLockedTarget(id)
        // Persist first so the choice survives even if the immediate select fails;
        // the next active-source change will retry the restore.
        persist()
        if controller.isEnabled, let id {
            _ = catalog.selectSource(id: id)
        }
    }

    private func persist() {
        settingsStore.save(
            LockSettings(
                isEnabled: controller.isEnabled,
                lockedTargetID: controller.lockedTargetID
            )
        )
    }
}
