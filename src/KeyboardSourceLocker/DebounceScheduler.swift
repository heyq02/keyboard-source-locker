public protocol DebounceTask: AnyObject {
    func cancel()
}

public protocol DebounceScheduler: AnyObject {
    func schedule(after delay: Duration, _ work: @escaping () -> Void) -> any DebounceTask
}
