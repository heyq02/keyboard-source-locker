# Agent notes

macOS menu-bar utility that locks the active keyboard input source (Swift Package + thin AppKit shell). Product intent: [docs/DEMAND.md](docs/DEMAND.md), [docs/PRD.md](docs/PRD.md). Architecture / seams: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Stack

- Swift **6.2+**, macOS **14+**, tools-version 6.2 in `Package.swift`
- Node orchestration via **Vite+** (`vp`) + **pnpm** (`packageManager` in `package.json`)
- Version source of truth: `package.json` (Swift `VersionTool` / `AppVersion` read it)

## Layout

| Path                          | Role                                                              |
| ----------------------------- | ----------------------------------------------------------------- |
| `src/KeyboardSourceLocker`    | Core library (lock policy, settings, TIS / SMAppService adapters) |
| `src/KeyboardSourceLockerApp` | Menu-bar AppKit entry                                             |
| `src/VersionTool`             | Prints version from `package.json`                                |
| `tests1/CoreTestRunner`        | CLT test harness (not XCTest / Swift Testing)                     |
| `scripts/*.mjs`               | Build / package / coverage helpers                                |
| `vite.config.ts`              | `run.tasks` for `vp run …`                                        |
| `Resources/Info.plist`        | Packaged `.app` metadata (`LSUIElement`, icon, copyright)         |
| `images/app-icon.jpg`         | Source art for `vp run icon` → `Resources/AppIcon.icns`           |

Target `path`s are explicit under `src/` in `Package.swift`.

## Commands

```bash
pnpm install
vp run test       # CoreTestRunner
vp run coverage   # instrumented tests; fail if line cover < 90% on src/KeyboardSourceLocker
vp run build      # KeyboardSourceLockerApp
vp run package    # dist/KeyboardSourceLocker.app (rebuilds AppIcon.icns)
vp run icon       # rebuild Resources/AppIcon.icns from images/app-icon.jpg
vp run version    # print package.json version via VersionTool
vp run check      # debug smoke build of products
vp run clean
pnpm run release  # bumpp → commit, tag vX.Y.Z, push (triggers Release workflow)
```

Task definitions live in `vite.config.ts` (`run.tasks`); do not duplicate them in `package.json` (except `release` / `changelog`).

## Testing

- Prefer extending `tests1/CoreTestRunner` over adding XCTest — CLT environments often lack a working XCTest / Swift Testing runner.
- Production seams: `InputSourceCatalog`, `DebounceScheduler`, `SettingsBackend`, `LaunchAtLoginServing`, `SMAppServiceControlling`.
- Coverage gate: `vp run coverage` (also used in CI Test workflow). Threshold via `COVERAGE_THRESHOLD` (default 90).

## Release

1. `pnpm run release` (or bump `package.json` + tag `v*`)
2. Tag push runs `.github/workflows/release.yml`: test → package → changelogithub → upload Release assets
3. Git tag must match `package.json` version
4. Distribute only via **GitHub Releases** (no GHCR)

## Conventions

- Conventional Commits (`feat:`, `fix:`, `chore:`, …) — Release notes come from changelogithub
- Debounce default: **200 ms**
- Keep the menu-bar app thin; put policy in `KeyboardSourceLocker`
