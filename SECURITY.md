# Security Policy

## Supported versions

| Version | Supported |
| --- | --- |
| `main` / latest release | ✅ |
| Older tags | ❌ Best-effort only |

## Reporting a vulnerability

If you discover a security issue (for example unexpected privilege use, unsafe handling of input-source data, or supply-chain concerns in packaging/CI):

1. **Do not** open a public GitHub issue
2. Contact the maintainer privately via GitHub: [@heyq02](https://github.com/heyq02)
3. Include a clear description, impact, and reproduction steps if possible

You can expect an initial response within **7 days**. If the report is confirmed, we will work on a fix and credit you unless you prefer to remain anonymous.

## Scope notes

This app:

- Reads and selects macOS Text Input Sources via public TIS APIs
- Stores lock preferences in `UserDefaults`
- Does **not** require Accessibility permissions for the current design

If future features request additional privileges, they will be documented here and in the README.
