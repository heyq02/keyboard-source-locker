import KeyboardSourceLocker

enum InputSourceLockControllerTests {
    static func run() {
        print("InputSourceLockController")
        lockOffDoesNotRestore()
        lockOnRestoresAfterDebounce()
        lockOnDoesNotRestoreBeforeDebounce()
        noRestoreWhenAlreadyOnTarget()
        retargetUsesNewLockedSource()
        disablingCancelsPendingRestore()
        rapidChangesOnlyRestoreOnceAfterSettle()
    }

    private static func lockOffDoesNotRestore() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: false,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(200))

        Expect.true(restored.isEmpty, "lock off does not restore after active source changes")
    }

    private static func lockOnRestoresAfterDebounce() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(200))

        Expect.equal(restored, [InputSourceID("wechat")], "lock on restores locked target after debounce")
    }

    private static func lockOnDoesNotRestoreBeforeDebounce() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(199))

        Expect.true(restored.isEmpty, "lock on does not restore before debounce elapses")
    }

    private static func noRestoreWhenAlreadyOnTarget() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("wechat"))
        scheduler.advance(by: .milliseconds(200))

        Expect.true(restored.isEmpty, "no restore when already on locked target")
    }

    private static func retargetUsesNewLockedSource() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.setLockedTarget(InputSourceID("abc"))
        controller.activeSourceDidChange(to: InputSourceID("wechat"))
        scheduler.advance(by: .milliseconds(200))

        Expect.equal(restored, [InputSourceID("abc")], "retarget uses new locked source immediately")
    }

    private static func disablingCancelsPendingRestore() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("abc"))
        controller.setEnabled(false)
        scheduler.advance(by: .milliseconds(200))

        Expect.true(restored.isEmpty, "disabling cancels pending restore")
    }

    private static func rapidChangesOnlyRestoreOnceAfterSettle() {
        let scheduler = ManualScheduler()
        var restored: [InputSourceID] = []
        let controller = InputSourceLockController(
            isEnabled: true,
            lockedTargetID: InputSourceID("wechat"),
            debounceInterval: .milliseconds(200),
            scheduler: scheduler,
            onRestore: { restored.append($0) }
        )

        controller.activeSourceDidChange(to: InputSourceID("abc"))
        scheduler.advance(by: .milliseconds(50))
        controller.activeSourceDidChange(to: InputSourceID("pinyin"))
        scheduler.advance(by: .milliseconds(200))

        Expect.equal(restored, [InputSourceID("wechat")], "rapid changes debounce to a single restore")
    }
}
