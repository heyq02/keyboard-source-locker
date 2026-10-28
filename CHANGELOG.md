# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Community docs: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Issue and pull request templates
- `Makefile` developer targets and architecture overview
- Menu **About** item linking to the GitHub project
- Dependabot updates for GitHub Actions

### Changed

- Split CI into push-triggered tests and tag-triggered releases
- Filter input-source picker to selectable keyboard sources only

## [0.1.0] - 2026-10-28

### Added

- Initial macOS menu-bar locker with debounced global restore
- Persistence of lock state and locked target
- `CoreTestRunner` TDD harness
- Packaging script and GitHub Actions workflows

[Unreleased]: https://github.com/heyq02/keyboard-source-locker/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/heyq02/keyboard-source-locker/releases/tag/v0.1.0
