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

The app appears in the menu bar (`lock` / `lock.open` icon):

- **Lock: On/Off** — toggle global locking
- **Select Input Source** — choose the locked target
- **Quit** — stop monitoring and exit

Default debounce is **200 ms**.
