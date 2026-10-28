# Contributing

Thanks for helping improve Keyboard Source Locker.

## Ground rules

- Be respectful — see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- Prefer small, focused pull requests
- Match existing naming and style (Swift 6, value types first)
- Keep product behavior aligned with [docs/PRD.md](docs/PRD.md)

## Development setup

1. Install macOS 14+ and Swift 6.2+ (Xcode or Command Line Tools)
2. Clone the repo and run the suite:

```bash
make test
```

Useful targets:

| Command | Purpose |
| --- | --- |
| `make test` | Run `CoreTestRunner` |
| `make build` | Compile the app |
| `make run` | Launch via SwiftPM |
| `make package` | Produce `dist/KeyboardSourceLocker.app` |

## Test-driven changes

Core policy lives under `Sources/KeyboardSourceLocker/`. Prefer adding a failing case in `Tests/CoreTestRunner/` first, then the minimal implementation.

Confirmed seams:

1. `InputSourceLockController` — debounce / enable / retarget
2. `LockSettingsStore` — persistence + missing-target handling
3. `InputSourceLockSession` + catalog protocol — wiring
4. `SelectableInputSources` — picker filtering

Menu-bar AppKit code is intentionally thin; keep logic out of `AppDelegate` when possible.

## Pull requests

1. Branch from `main`
2. Keep commits readable; squash locally if helpful
3. Ensure `make test` and `make build` pass
4. Describe **why** and how you verified the change
5. Link related issues

## Reporting bugs

Use the [bug report template](https://github.com/heyq02/keyboard-source-locker/issues/new?template=bug_report.yml). Include macOS version, input sources involved, and steps to reproduce.

## Security

Please do **not** open public issues for security vulnerabilities — see [SECURITY.md](SECURITY.md).
