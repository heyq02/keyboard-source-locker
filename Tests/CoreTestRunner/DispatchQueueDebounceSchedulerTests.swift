import Foundation
import KeyboardSourceLocker

enum DispatchQueueDebounceSchedulerTests {
    static func run() {
        print("DispatchQueueDebounceScheduler")
        runsWorkAfterDelay()
        cancelPreventsWork()
        convertsDurationToTimeInterval()
    }

    private static func runsWorkAfterDelay() {
        let queue = DispatchQueue(label: "KeyboardSourceLocker.tests.debounce")
        let scheduler = DispatchQueueDebounceScheduler(queue: queue)
        let lock = NSLock()
        var ran = false
        let sem = DispatchSemaphore(value: 0)

        _ = scheduler.schedule(after: .milliseconds(30)) {
            lock.lock()
            ran = true
            lock.unlock()
            sem.signal()
        }

        let waitResult = sem.wait(timeout: .now() + 1)
        lock.lock()
        let didRun = ran
        lock.unlock()

        Expect.equal(waitResult, .success, "work completes within timeout")
        Expect.true(didRun, "runs scheduled work after delay")
    }

    private static func cancelPreventsWork() {
        let queue = DispatchQueue(label: "KeyboardSourceLocker.tests.debounce.cancel")
        let scheduler = DispatchQueueDebounceScheduler(queue: queue)
        let lock = NSLock()
        var ran = false

        let task = scheduler.schedule(after: .milliseconds(120)) {
            lock.lock()
            ran = true
            lock.unlock()
        }
        task.cancel()
        Thread.sleep(forTimeInterval: 0.25)

        lock.lock()
        let didRun = ran
        lock.unlock()
        Expect.true(!didRun, "cancel prevents scheduled work")
    }

    private static func convertsDurationToTimeInterval() {
        let seconds = Duration.seconds(1).timeInterval
        let millis = Duration.milliseconds(250).timeInterval
        Expect.true(abs(seconds - 1.0) < 0.000_001, "Duration.seconds maps to TimeInterval")
        Expect.true(abs(millis - 0.25) < 0.000_001, "Duration.milliseconds maps to TimeInterval")
    }
}
