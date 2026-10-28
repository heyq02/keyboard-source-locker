import KeyboardSourceLocker

final class ManualScheduler: DebounceScheduler {
    private struct Item {
        let fireAt: Duration
        let work: () -> Void
        let task: TaskHandle
    }

    final class TaskHandle: DebounceTask {
        var isCancelled = false
        func cancel() { isCancelled = true }
    }

    private var now: Duration = .zero
    private var items: [Item] = []

    func schedule(after delay: Duration, _ work: @escaping () -> Void) -> any DebounceTask {
        let handle = TaskHandle()
        items.append(Item(fireAt: now + delay, work: work, task: handle))
        return handle
    }

    func advance(by delta: Duration) {
        now += delta
        let due = items.filter { $0.fireAt <= now }
        items.removeAll { $0.fireAt <= now }
        for item in due where !item.task.isCancelled {
            item.work()
        }
    }
}
