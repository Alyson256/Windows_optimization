# Risks & Details

Transparent breakdown of what each script does, which registry keys it touches, and what the risks are.

---

## 02 — Services → Manual

**Risk: 🟢 Low**

Sets `start=demand` (Manual), NOT `start=disabled`.  
The service will still launch if Windows or another application requests it.

| Service | Default | Changed to | Impact if stopped |
|---------|---------|------------|-------------------|
| SysMain | Automatic | Manual | No disk pre-caching. Negligible on SSDs. |
| WSearch | Automatic | Manual | Search indexing paused. File search still works. |
| DiagTrack | Automatic | Manual | Telemetry stops uploading. |
| XblAuthManager | Automatic | Manual | Xbox Live login may prompt on first use. |
| RemoteRegistry | Automatic | Manual | Remote registry editing disabled. |

---

## 03 — Disable Windows Recall

**Risk: 🟢 Low**

Writes `DisableAIDataAnalysis = 1` to Group Policy keys:
- `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI`
- `HKCU\Software\Policies\Microsoft\Windows\WindowsAI`

These are **policy keys** — they override user settings but can be removed cleanly.
Only affects Windows 11 24H2+ builds (≥ 26100).

---

## 04 — Disable Telemetry

**Risk: 🟢 Low**

- Sets `AllowTelemetry = 0` in two policy paths.
- On Windows 11 **Home**, Microsoft may enforce a minimum of level 1 (Basic) despite the key being set to 0. This is by design. The key is still written.
- Does NOT modify the `hosts` file (no risk of blocking Windows Update CDN).

### Optional: Hosts file blocking
If you want to block telemetry endpoints at the network level, you can manually add entries to `C:\Windows\System32\drivers\etc\hosts`. This is not done automatically because it can occasionally block legitimate Microsoft services (e.g., update CDNs that share IPs).

---

## 05 — Power Plan

**Risk: 🟢 Low**

- High Performance plan draws more power — relevant only for laptops on battery.
- Disabling hibernation removes `hiberfil.sys` (~size of RAM). This is irreversible from this script; re-run `10_undo_all.bat` or run `powercfg /h on` manually.
- Disabling Fast Startup means slightly slower shutdown. This is intentional — Fast Startup is a hybrid-sleep that can cause driver state issues on wake.

---

## 06 — Visual Tweaks

**Risk: 🟢 Low / 🟢 None**

All changes are in `HKCU` (current user only). ClearType is explicitly preserved.  
Explorer is restarted automatically — taskbar will flicker briefly.

---

## 07 — Network Tweaks

**Risk: 🟡 Medium**

- **Nagle Algorithm off**: Can slightly increase upload bandwidth usage (more small packets). Beneficial for gaming, video calls, and SSH. No downside for most broadband connections.
- **ECN disabled**: Rare routers don't support ECN and may drop connections. Disabling it avoids this edge case.
- **NetworkThrottlingIndex**: Setting to `0xFFFFFFFF` removes Windows' background throttling on multimedia streams. Beneficial for gaming and DAW software.

---

## 08 — Privacy Tweaks

**Risk: 🟢 None**

All keys are either `HKCU` (user-level) or policy keys that Windows reads but doesn't depend on for stability.  
Camera/microphone access is **not** changed — those remain user-controllable in Settings > Privacy.

---

## 09 — Startup Audit

**Risk: None (read-only)**

Outputs a list of startup registry entries and scheduled tasks. No changes made.

---

## 10 — Undo All

**Risk: 🟢 None**

Restores defaults by **deleting policy keys** (the cleanest approach — avoids writing wrong values).  
Services are set back to `start=auto`. Visual effects return to "Let Windows decide".
