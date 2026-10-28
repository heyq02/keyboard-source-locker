import Foundation

enum Expect {
    nonisolated(unsafe) private static var failures = 0
    nonisolated(unsafe) private static var passes = 0

    static func `true`(_ condition: Bool, _ message: String, file: StaticString = #fileID, line: UInt = #line) {
        if condition {
            passes += 1
            print("  ✔ \(message)")
        } else {
            failures += 1
            print("  ✘ \(message) (\(file):\(line))")
        }
    }

    static func equal<T: Equatable>(_ actual: T, _ expected: T, _ message: String, file: StaticString = #fileID, line: UInt = #line) {
        `true`(actual == expected, "\(message) — got \(actual), expected \(expected)", file: file, line: line)
    }

    static func finish() -> Int32 {
        print("\n\(passes) passed, \(failures) failed")
        return failures == 0 ? 0 : 1
    }
}
