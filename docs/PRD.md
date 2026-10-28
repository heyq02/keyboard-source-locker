# PRD: Keyboard Source Locker

| Field | Value |
| --- | --- |
| Product | Keyboard Source Locker |
| Version | v1 |
| Status | Draft from accepted DEMAND |
| Platform | macOS |
| Source | [DEMAND.md](./DEMAND.md) |
| Last updated | 2026-10-28 |

---

## 1. Summary

Keyboard Source Locker is a lightweight **macOS menu-bar app** that lets the user pick any installed keyboard input source and **keep it locked** as the active source. When macOS switches away (for example to built-in **ABC**), the app restores the locked target after a short debounce.

v1 does not remove system input sources; it overrides unwanted switches while the locker is enabled.

---

## 2. Problem

### 2.1 Context

macOS Input Sources can include:

- Built-in layouts such as **ABC**
- Third-party IMEs such as **微信输入法**

ABC generally cannot be removed from the Input Sources list. Third-party sources can. Because ABC remains available, the active source can change to ABC (or another source) without the user meaning to.

### 2.2 User pain

Users who prefer one input source keep getting switched away. There is no built-in “pin this input source” control, and deleting ABC is not a viable workaround.

### 2.3 Opportunity

A small always-available menu-bar utility can watch the active input source and restore the user’s chosen target, without fighting System Settings or modifying third-party IMEs.

---

## 3. Goals and non-goals

### 3.1 Goals (v1)

1. Let the user choose **any installed** input source as the locked target.
2. Keep that lock **global** (same target for all apps) while enabled.
3. Restore the locked target after a **short debounce** when the active source changes away from it.
4. Ship as a **menu-bar app** with status, lock toggle, target picker, and quit.
5. Persist the user’s lock-enabled state and chosen target across app launches.

### 3.2 Non-goals (v1)

- Removing ABC or any built-in source from System Settings
- Per-app / per-context lock profiles
- Editing IME internals (layouts, dictionaries, shortcuts inside 微信输入法, etc.)
- Windows / Linux support
- Cloud sync, accounts, or telemetry-heavy product surfaces

---

## 4. Users and use cases

### 4.1 Primary user

macOS user who types mainly with one preferred input source (often a third-party Chinese IME) and is annoyed by unexpected switches to ABC or other sources.

### 4.2 Core use cases

| ID | Use case | Outcome |
| --- | --- | --- |
| UC-1 | Enable lock on preferred source | While enabled, active source stays on the chosen target |
| UC-2 | Change locked target | New target is used for restore immediately; no restart required |
| UC-3 | Temporarily unlock | Toggle off → normal macOS switching resumes; app stays in menu bar |
| UC-4 | Quit app | Locking stops; normal macOS switching resumes |
| UC-5 | Unwanted system/app switch | After short debounce, active source returns to locked target |

---

## 5. Product requirements

### 5.1 Menu-bar experience

The app runs as a menu-bar–first utility (no required main window for v1).

**Menu must support:**

| Action | Requirement |
| --- | --- |
| Status | Show whether lock is On/Off and which source is locked |
| Toggle lock | Enable / disable locking without quitting |
| Pick target | Choose any currently installed input source |
| Quit | Exit the app and stop all restore behavior |

Optional for v1 (nice-to-have, not required): About, Launch at Login, open System Settings → Keyboard.

### 5.2 Locking behavior

| Rule | Detail |
| --- | --- |
| Scope | Global — one locked target for the whole system while enabled |
| Target | Any input source currently installed / available to the user |
| Detection | Observe changes to the active input source |
| Restore | If active ≠ locked target and lock is On → switch back after short debounce |
| Debounce | Short delay before restore (recommended default **150–300 ms**; exact value tunable in implementation) |
| Continuous | Watch/restore loop while the app is running and lock is On — not a one-shot action |
| Target change | Updating the locked target takes effect immediately for subsequent restores |
| Disable / quit | Stop restoring; leave the current active source as-is |

### 5.3 Persistence

On launch, restore last-known:

- Lock enabled / disabled
- Locked target identity (stable ID preferred over display name)

If the previously locked target is no longer installed, disable lock (or prompt via menu status) and require the user to pick a new target. Do not silently pick a different source.

### 5.4 Permissions and system integration

- Use public macOS APIs for listing / reading / selecting input sources (e.g. Input Source / Text Input Services APIs as appropriate).
- Request only the privileges required for input-source control.
- If permission or capability is missing, show a clear menu/status message rather than failing silently.

---

## 6. Functional requirements

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-1 | List installed input sources in the menu for selection | P0 |
| FR-2 | Persist and display the currently locked target | P0 |
| FR-3 | Toggle lock On/Off from the menu bar | P0 |
| FR-4 | While On, detect active-source changes system-wide | P0 |
| FR-5 | Restore locked target after short debounce when active source differs | P0 |
| FR-6 | Changing locked target applies without app restart | P0 |
| FR-7 | Quit stops monitoring and restoring | P0 |
| FR-8 | Persist lock state + target across launches | P0 |
| FR-9 | Handle missing locked target after uninstall/removal of that source | P1 |
| FR-10 | Launch at Login | P2 |

---

## 7. Non-functional requirements

| ID | Area | Requirement |
| --- | --- | --- |
| NFR-1 | Performance | Restore path must feel near-instant after debounce; no noticeable typing lag |
| NFR-2 | Resource use | Idle CPU/memory footprint appropriate for an always-on menu-bar utility |
| NFR-3 | Reliability | Survive common triggers: app focus change, menu-bar input switch, keyboard shortcut switch |
| NFR-4 | Safety | Never delete or reconfigure system Input Sources lists |
| NFR-5 | UX clarity | Locked vs unlocked state must be obvious from the menu (and ideally the menu-bar icon) |
| NFR-6 | Compatibility | Support recent macOS versions targeted by the implementation (document minimum OS in engineering notes) |

---

## 8. UX outline (v1)

```
[Menu bar icon]
  ├─ Lock: On  ✓   (or Off)
  ├─ Locked to: 微信输入法
  ├─ ────────────
  ├─ Select Input Source
  │    ├─ ABC
  │    ├─ 微信输入法  ✓
  │    └─ …
  ├─ ────────────
  └─ Quit
```

Notes:

- Selecting a source sets it as the locked target; if lock is On, switch to it (subject to debounce rules as needed).
- Icon should differentiate locked vs unlocked if practical (P1).

---

## 9. Success metrics (v1 qualitative)

v1 is a personal / small utility; success is behavioral, not growth KPIs:

1. With lock On, unexpected ABC (or other) switches do not stick past the debounce window.
2. User can change target and toggle lock without quitting or restarting.
3. Quitting fully returns control to macOS input switching.
4. App remains usable as a background menu-bar citizen (low friction, low resource use).

---

## 10. Acceptance criteria

Mapped from accepted [DEMAND.md](./DEMAND.md):

- [x] User can choose any currently installed input source as the locked target.
- [x] While the locker is enabled, the lock applies system-wide (not limited to specific apps).
- [x] Switching away from the locked target (including to ABC) results in a return to that target after a short debounce.
- [x] The locked target is restored across common triggers (app focus change, shortcut switch, menu bar switch).
- [x] Changing the locked target updates restore behavior without requiring a restart.
- [x] Delivered as a menu-bar app (status, toggle, target picker, quit).
- [x] Disabling or quitting the locker restores normal macOS input-source switching.
- [x] No need for the user to remove ABC from Input Sources.

### 10.1 Verification checklist (for implementation / QA)

| Check | Pass condition |
| --- | --- |
| Pick target | Every listed installed source can be selected as locked target |
| Global lock | Switch apps; lock target unchanged and still enforced |
| Debounced restore | Manual switch away → returns to locked target after short delay |
| Shortcut / menu switch | Both trigger restore while lock On |
| Retarget | Change target mid-session; next restore uses new target |
| Toggle Off | No automatic restores while Off |
| Quit | No further restores after quit |
| Persistence | Relaunch restores prior On/Off + target |

---

## 11. Risks and open implementation details

| Topic | Note | Owner at build time |
| --- | --- | --- |
| Exact debounce ms | DEMAND requires short debounce; PRD recommends 150–300 ms default | Engineering |
| Input source identity | Prefer stable source ID over localized display name for persistence | Engineering |
| Accessibility / privacy prompts | May be required depending on APIs used; must be documented for users | Engineering |
| IME startup races | Some IMEs may briefly report transitional states; debounce should absorb this | Engineering |
| Menu-bar icon states | Locked/unlocked visual distinction is P1 | Design / Engineering |

---

## 12. Milestones (suggested)

| Milestone | Deliverable |
| --- | --- |
| M1 | Menu-bar shell: icon, menu, quit |
| M2 | List sources + select locked target + persistence |
| M3 | Detect active source + debounced restore while lock On |
| M4 | Hardening: missing target, common switch triggers, polish |

---

## 13. Appendix

### 13.1 Reference UI (problem evidence)

- Built-in ABC cannot be removed like third-party sources: `images/abc-input-source.png`
- Third-party example (微信输入法): `images/wx-input-source.png`

### 13.2 Glossary

| Term | Meaning |
| --- | --- |
| Input source | A keyboard layout or IME selectable in macOS Input Sources |
| Locked target | The user-chosen input source the app keeps restoring to |
| Short debounce | Brief delay before restore to avoid fighting momentary switches |
| Global lock | One locked target enforced for all apps while enabled |
