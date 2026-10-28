# Keyboard Source Locker

macOS menu-bar utility that locks the active keyboard input source to a user-chosen target (see [docs/PRD.md](docs/PRD.md)).

## Requirements

- macOS 14+
- Swift 6.3 toolchain (`xcode-select` Command Line Tools or Xcode)

## Test (TDD entrypoint)

Command Line Tools alone do not run XCTest / Swift Testing reliably, so core behavior is verified with:

```bash
swift run CoreTestRunner
```

## Run the app

```bash
swift run KeyboardSourceLockerApp
```

Or package a menu-bar `.app` (LSUIElement, no Dock icon):

```bash
Scripts/package-app.sh release
open dist/KeyboardSourceLocker.app
```

The app appears in the menu bar (`lock` / `lock.open` icon):

- **Lock: On/Off** — toggle global locking
- **Select Input Source** — choose the locked target
- **Quit** — stop monitoring and exit

Default debounce is **200 ms**.

## CI

| Workflow | Trigger | What it does |
| --- | --- | --- |
| [Test](.github/workflows/test.yml) | Every push / PR | Runs `CoreTestRunner` and compiles the app |
| [Release](.github/workflows/release.yml) | Git tags `v*` | Tests, packages `.app`, creates a GitHub Release |

Publish a release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The release attaches `KeyboardSourceLocker-vX.Y.Z-macos.zip` and the raw `KeyboardSourceLockerApp` binary.

