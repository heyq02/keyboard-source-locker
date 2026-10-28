# Keyboard Source Locker

## Background

On macOS, System Settings → Keyboard → Input Sources lists both built-in and third-party sources, for example:

- **ABC** — the built-in English layout
- **微信输入法** (WeChat Input Method) — a third-party input source

ABC cannot be removed from the list (the “−” control is effectively unavailable for it). Third-party sources can be removed. Because ABC always remains available, the system can switch the active input source to ABC (or another unwanted source) unexpectedly during normal use.

## Problem

Users who prefer a specific input source still get switched away from it without intending to. There is no built-in way to remove ABC or permanently pin a preferred input source, so the unwanted switch keeps happening.

## Goal

Provide a lightweight **macOS menu-bar app** that lets the user **choose any installed input source and lock the active keyboard to it**, so the system does not stay on (or keep drifting back to) an unwanted source such as ABC.

## Proposed Behavior

1. List installed input sources and let the user pick one as the **locked target**.
2. Apply the lock **globally** — same locked target for all apps and contexts while enabled.
3. Detect the current active input source.
4. If it is not the locked target, restore it after a **short debounce** (not immediate), so brief intentional switches are less likely to fight the locker.
5. Keep this lock in effect while the utility is running (continuous watch / restore, not a one-shot toggle).
6. Live in the menu bar: show status, toggle lock on/off, pick the locked target, and quit.
7. Allow changing the locked target at any time; the new choice takes effect immediately.

## Out of Scope (for v1)

- Removing ABC (or any built-in source) from System Settings.
- Per-app or per-context lock profiles (different targets for different apps).
- Changing keyboard shortcuts, layouts, or IME-internal settings of third-party input methods.

## Acceptance Criteria

- [x] User can choose any currently installed input source as the locked target.
- [x] While the locker is enabled, the lock applies system-wide (not limited to specific apps).
- [x] Switching away from the locked target (including to ABC) results in a return to that target after a short debounce.
- [x] The locked target is restored across common triggers (app focus change, shortcut switch, menu bar switch).
- [x] Changing the locked target updates restore behavior without requiring a restart.
- [x] Delivered as a menu-bar app (status, toggle, target picker, quit).
- [x] Disabling or quitting the locker restores normal macOS input-source switching.
- [x] No need for the user to remove ABC from Input Sources.
