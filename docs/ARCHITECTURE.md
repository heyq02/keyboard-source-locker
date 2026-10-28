# Architecture

Keyboard Source Locker is a Swift Package with three products:

| Product                   | Role                                                     |
| ------------------------- | -------------------------------------------------------- |
| `KeyboardSourceLocker`    | Pure-ish core library (policy, persistence, TIS adapter) |
| `KeyboardSourceLockerApp` | Thin AppKit menu-bar shell                               |
| `CoreTestRunner`          | Executable test harness (CLT-friendly)                   |

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
3. **`InputSourceCatalog`** — list / read active / select; production uses `TISInputSourceCatalog`. The protocol is `@MainActor` because TIS must be driven from the main thread; `TISInputSourceCatalog` caches its record index and rebuilds it on a cache miss.
4. **`SelectableInputSources`** — filters keyboard + select-capable sources for the picker.

`InputSourceLockSession` is `@MainActor` and owns the app-facing API. `stop()` only detaches the observer and disables the controller in memory — persisted settings are left untouched so a later `start()` resumes the user's previous lock state.

## Debounce

Default interval is **200 ms**. Rapid successive switches cancel the previous pending restore so only the settled active source triggers one restore.

## Packaging

`vp run package` → `scripts/package.mjs` builds a release binary into `dist/KeyboardSourceLocker.app` with `static/Info.plist` (`LSUIElement` = menu-bar only) and ad-hoc codesign. Version comes from `package.json` via Swift `VersionTool`. Node orchestration uses [Vite+](https://viteplus.dev) (`vite.config.ts` `run.tasks`).
