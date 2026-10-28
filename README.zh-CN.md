# Keyboard Source Locker

[English](./README.md) | 简体中文

[![Test](https://github.com/heyq02/keyboard-source-locker/actions/workflows/test.yml/badge.svg)](https://github.com/heyq02/keyboard-source-locker/actions/workflows/test.yml)
[![Release](https://github.com/heyq02/keyboard-source-locker/actions/workflows/release.yml/badge.svg)](https://github.com/heyq02/keyboard-source-locker/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

macOS 菜单栏小工具：把当前键盘输入法锁定为你指定的那一个。系统不允许移除内置的 **ABC**，因此有时会意外切过去——本应用会在短暂防抖后把输入法切回你的偏好。

<p align="center">
  <img src="images/hero-banner.jpg" alt="Keyboard Source Locker" width="800" />
</p>

## 安装

1. 下载最新 [Release](https://github.com/heyq02/keyboard-source-locker/releases/latest) 中的 zip
2. 解压后将 `KeyboardSourceLocker.app` 拖到 `/Applications`
3. 打开应用 —— 在菜单栏找到锁图标（无 Dock 图标）

首次从网络下载启动时，可能需要到 **系统设置 → 隐私与安全性 → 仍要打开**。

## 使用

1. 点击菜单栏锁图标 → **Select Input Source** → 选择目标输入法（例如微信输入法）
2. 打开 **Lock: On**
3. 再切到 ABC（或其他输入法）时，约 200 ms 后会自动切回

菜单中还有：登录时启动、Version、About、Quit。登录时启动建议使用打包好的 `.app`。

需要 **macOS 14+**。

## 许可证

<!-- automd:contributors author="heyq02" license="MIT" -->

Published under the [MIT](https://github.com/heyq02/keyboard-source-locker/blob/main/LICENSE) license.
Made by [@heyq02](https://github.com/heyq02) and [community](https://github.com/heyq02/keyboard-source-locker/graphs/contributors) 💛
<br><br>
<a href="https://github.com/heyq02/keyboard-source-locker/graphs/contributors">
<img src="https://contrib.rocks/image?repo=heyq02/keyboard-source-locker" />
</a>

<!-- /automd -->

<!-- automd:with-automd -->

---

_🤖 auto updated with [automd](https://automd.unjs.io)_

<!-- /automd -->

