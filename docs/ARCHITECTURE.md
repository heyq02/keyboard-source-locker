# Architecture

Keyboard Source Locker is a Swift Package with three products:

| Product | Role |
| --- | --- |
| `KeyboardSourceLocker` | Pure-ish core library (policy, persistence, TIS adapter) |
| `KeyboardSourceLockerApp` | Thin AppKit menu-bar shell |
| `CoreTestRunner` | Executable test harness (CLT-friendly) |

```
┌─────────────────────────────────────────────┐
│              Menu bar (AppKit)              │
│         AppDelegate → session API           │
└──────────────────────┬──────────────────────┘
                       │
┌──────────────────────▼──────────────────────┐
│           InputSourceLockSession            │
│  start/stop · setEnabled · setLockedTarget  │
└───────┬──────────────────────────┬──────────┘
        │                          │
        ▼                          ▼
 InputSourceCatalog         LockSettingsStore
 (TIS / Fake)               (UserDefaults / Memory)
        │
        ▼
 InputSourceLockController  ← DebounceScheduler
 (restore decision)           (DispatchQueue / Manual)
```

## Seams

1. **`InputSourceLockController`** — given enablement, locked target, and active-source changes, schedules debounced restores.
2. **`LockSettingsStore`** — persists `isEnabled` + target ID; disables lock when the target is no longer installed.
3. **`InputSourceCatalog`** — list / read active / select; production uses `TISInputSourceCatalog`.
4. **`SelectableInputSources`** — filters keyboard + select-capable sources for the picker.

## Debounce

Default interval is **200 ms**. Rapid successive switches cancel the previous pending restore so only the settled active source triggers one restore.

## Packaging

`Scripts/package-app.sh` builds a release binary into `dist/KeyboardSourceLocker.app` with `Resources/Info.plist` (`LSUIElement` = menu-bar only) and ad-hoc codesign.
