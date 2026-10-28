import Foundation

public final class DispatchQueueDebounceScheduler: DebounceScheduler {
    private final class WorkItemTask: DebounceTask {
        let item: DispatchWorkItem
        init(_ item: DispatchWorkItem) { self.item = item }
        func cancel() { item.cancel() }
    }

    private let queue: DispatchQueue

    public init(queue: DispatchQueue = .main) {
        self.queue = queue
    }

    public func schedule(after delay: Duration, _ work: @escaping () -> Void) -> any DebounceTask {
        let item = DispatchWorkItem(block: work)
        queue.asyncAfter(deadline: .now() + delay.timeInterval, execute: item)
        return WorkItemTask(item)
    }
}

extension Duration {
    public var timeInterval: TimeInterval {
        let components = self.components
        return TimeInterval(components.seconds)
            + TimeInterval(components.attoseconds) / 1_000_000_000_000_000_000
    }
}
