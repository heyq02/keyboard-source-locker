# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Menu shows the current **Version**
- **Launch at Login** toggle (via `SMAppService`)

## [0.0.2] - 2026-10-28

### Added

- Community docs: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Issue and pull request templates, Dependabot for GitHub Actions
- `Makefile` developer targets and architecture overview
- Menu **About** item linking to the GitHub project
- Branding images (app icon, hero banner, menu preview) in the README
- GitHub Sponsors / Ko-fi funding links

### Changed

- Polished README for install, usage, and contributor onboarding
- Release packaging stamps version from the git tag and attaches a SHA-256 checksum

## [0.0.1] - 2026-10-28

### Added

- Initial macOS menu-bar locker with debounced global restore
- Persistence of lock state and locked target
- Selectable keyboard-source filtering (drops palette / non-selectable IME parents)
- `CoreTestRunner` TDD harness
- Packaging script and split Test / Release GitHub Actions workflows

[Unreleased]: https://github.com/heyq02/keyboard-source-locker/compare/v0.0.2...HEAD
[0.0.2]: https://github.com/heyq02/keyboard-source-locker/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/heyq02/keyboard-source-locker/releases/tag/v0.0.1
