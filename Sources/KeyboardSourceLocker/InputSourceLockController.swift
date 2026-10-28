public final class InputSourceLockController {
    public private(set) var isEnabled: Bool
    public private(set) var lockedTargetID: InputSourceID?

    private let debounceInterval: Duration
    private let scheduler: any DebounceScheduler
    private let onRestore: (InputSourceID) -> Void
    private var pendingTask: (any DebounceTask)?

    public init(
        isEnabled: Bool = false,
        lockedTargetID: InputSourceID? = nil,
        debounceInterval: Duration = .milliseconds(200),
        scheduler: any DebounceScheduler,
        onRestore: @escaping (InputSourceID) -> Void
    ) {
        self.isEnabled = isEnabled
        self.lockedTargetID = lockedTargetID
        self.debounceInterval = debounceInterval
        self.scheduler = scheduler
        self.onRestore = onRestore
    }

    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled {
            cancelPendingRestore()
        }
    }

    public func setLockedTarget(_ id: InputSourceID?) {
        lockedTargetID = id
    }

    public func activeSourceDidChange(to id: InputSourceID) {
        cancelPendingRestore()

        guard isEnabled else { return }
        guard let lockedTargetID, id != lockedTargetID else { return }

        pendingTask = scheduler.schedule(after: debounceInterval) { [weak self] in
            guard let self else { return }
            self.pendingTask = nil
            guard self.isEnabled, let target = self.lockedTargetID else { return }
            self.onRestore(target)
        }
    }

    private func cancelPendingRestore() {
        pendingTask?.cancel()
        pendingTask = nil
    }
}
