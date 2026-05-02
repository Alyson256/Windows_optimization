<div align="center">

# 🪟 win-optimizer

**Post-install Windows 11 optimization scripts — safe, documented, and fully reversible.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows 11](https://img.shields.io/badge/Windows-11-0078D4?logo=windows)](https://www.microsoft.com/windows/windows-11)
[![Batch + PowerShell](https://img.shields.io/badge/Batch_%2B_PowerShell-hybrid-5391FE?logo=powershell)](scripts/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## ✨ What it does

A collection of `.bat` scripts (with inline PowerShell for system ops) designed to make a clean Windows 11 install feel faster, quieter, and more private — **without touching anything that would break your system**.

Every script is:
- ✅ **Safe** — targets only non-essential services and policy registry keys
- ✅ **Reversible** — `10_undo_all.bat` restores Windows defaults
- ✅ **Transparent** — each change is logged with a timestamp
- ✅ **Documented** — see [docs/RISKS.md](docs/RISKS.md) for a full breakdown

---

## 🚀 Quick Start

> **Requires:** Windows 11, Administrator privileges.

```batch
git clone https://github.com/YOUR_USER/win-optimizer.git
cd win-optimizer\scripts

:: Right-click > Run as administrator
00_run_all.bat
```

You can also run each script **individually** — they work standalone.

---

## 📂 Project Structure

```
win-optimizer/
├── scripts/
│   ├── 00_run_all.bat          ← Master launcher (admin auto-elevation)
│   ├── 01_restore_point.bat    ← Creates restore point FIRST
│   ├── 02_services_manual.bat  ← Non-essential services → Manual
│   ├── 03_disable_recall.bat   ← Disable Windows Recall (AI snapshots)
│   ├── 04_disable_telemetry.bat← Telemetry + DiagTrack off
│   ├── 05_power_plan.bat       ← High Performance plan
│   ├── 06_visual_tweaks.bat    ← Disable animations/transparency
│   ├── 07_network_tweaks.bat   ← Nagle off, TCP tuning, DNS cache
│   ├── 08_privacy_tweaks.bat   ← Ads ID, location, activity history
│   ├── 09_startup_cleanup.bat  ← Startup audit (read-only)
│   ├── 10_undo_all.bat         ← Revert EVERYTHING to defaults
│   └── _lib/                   ← Shared: colors, logger, admin-check
└── tools/
    └── check_status.bat        ← Audit current state (no changes)
```

---

## 📋 Scripts Reference

| Script | Category | Risk | Reversible |
|--------|----------|------|-----------|
| `01_restore_point` | Safety | None | — |
| `02_services_manual` | Performance | 🟢 Low | ✓ |
| `03_disable_recall` | Privacy | 🟢 Low | ✓ |
| `04_disable_telemetry` | Privacy | 🟢 Low | ✓ |
| `05_power_plan` | Performance | 🟢 Low | ✓ |
| `06_visual_tweaks` | Performance | 🟢 Low | ✓ |
| `07_network_tweaks` | Performance | 🟡 Medium | ✓ |
| `08_privacy_tweaks` | Privacy | 🟢 Low | ✓ |
| `09_startup_cleanup` | Audit | None (read-only) | — |
| `10_undo_all` | Revert | None | — |
| `check_status` | Audit | None (read-only) | — |

> Full risk description for each script: [docs/RISKS.md](docs/RISKS.md)

---

## 🔄 Reverting Changes

Run `10_undo_all.bat` as Administrator to restore all settings to Windows defaults.
Alternatively, use the System Restore point created in step 01.

---

## 📦 What is NOT changed

To avoid any chance of breaking your system, these are intentionally left alone:

- ❌ No hosts file modifications (see [docs/RISKS.md](docs/RISKS.md) for optional extra steps)
- ❌ No Windows Defender / Security Center changes
- ❌ No core Windows Update policy changes
- ❌ No hardware driver tweaks
- ❌ No CPU/GPU overclocking

---

## 🌐 Português

Documentação em PT-BR disponível em [docs/pt-BR.md](docs/pt-BR.md).

---

## 🤝 Contributing

Issues and PRs are welcome! Please read [docs/RISKS.md](docs/RISKS.md) before submitting new tweaks.
New scripts must follow the `_lib/` conventions (admin check, logger, colors) and must include a corresponding undo step in `10_undo_all.bat`.

---

## 📄 License

MIT — see [LICENSE](LICENSE).
