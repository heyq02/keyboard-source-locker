# Keyboard Source Locker

[![Test](https://github.com/heyq02/keyboard-source-locker/actions/workflows/test.yml/badge.svg)](https://github.com/heyq02/keyboard-source-locker/actions/workflows/test.yml)
[![Release](https://github.com/heyq02/keyboard-source-locker/actions/workflows/release.yml/badge.svg)](https://github.com/heyq02/keyboard-source-locker/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

macOS menu-bar app that locks the active keyboard input source. macOS will not let you remove **ABC**, so the system can switch to it unexpectedly — this app restores your preferred source after a short debounce.

<p align="center">
  <img src="images/hero-banner.jpg" alt="Keyboard Source Locker" width="800" />
</p>

## Install

1. Download the latest [Release](https://github.com/heyq02/keyboard-source-locker/releases/latest) zip
2. Unzip and move `KeyboardSourceLocker.app` to `/Applications`
3. Launch — look for the lock icon in the menu bar (no Dock icon)

First launch may need **System Settings → Privacy & Security → Open Anyway**.

## Usage

1. Menu bar lock icon → **Select Input Source** → pick a target (e.g. 微信输入法)
2. Turn **Lock: On**
3. Switching to ABC (or anything else) snaps back after ~200 ms

Also in the menu: Launch at Login, Version, About, Quit. Launch at Login works best from the packaged `.app`.

Requires **macOS 14+**.

## License

<!-- automd:contributors provider="markupgo" author="heyq02" license="MIT" -->

Published under the [MIT](https://github.com/heyq02/keyboard-source-locker/blob/main/LICENSE) license.
Made by [@heyq02](https://github.com/heyq02) and [community](https://github.com/heyq02/keyboard-source-locker/graphs/contributors) 💛
<br><br>
<a href="https://github.com/heyq02/keyboard-source-locker/graphs/contributors">
<img src="https://markupgo.com/github/heyq02/keyboard-source-locker/contributors?circleSize=64&center=true&removeLogo=true" />
</a>

<!-- /automd -->

<!-- automd:with-automd -->

---

_🤖 auto updated with [automd](https://automd.unjs.io)_

<!-- /automd -->
