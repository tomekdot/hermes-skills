---
name: computer-use-cua-firefox
description: Reliable patterns for driving Firefox in AI Studio / Gemini through cua-driver on Windows. Use when browser automation must enter prompts into AI Studio, read back replies, or interact with the bottom input bar.
version: 0.2.0
metadata:
  hermes:
    tags: [computer-use, firefox, ai-studio, cua-driver, windows, automation, browser]
---

# 🖥️ CUA Firefox + AI Studio Automation

## 📋 Overview

Firefox on Windows is **not safely queryable by UIA `get_window_state`** for complex pages like Google AI Studio. This skill encodes the proven fallback sequence based on real testing on `MozillaWindowClass`.

**Always use this workflow when:**
- Typing a prompt into Google AI Studio in Firefox
- Reading back the current AI Studio conversation via vision
- Interacting with the bottom input bar / Run button

---

## 🔁 Canonical Workflow (tested, working)

### 1. Locate the Firefox window
```text
mcp_cua_driver_list_windows(on_screen_only=true)
```
- Target window title contains: `Mozilla Firefox` or `Google AI Studio`
- Known identifiers for AI Studio on this machine:
  - `pid=15356`
  - `window_id=11470172`
  - Window class: `MozillaWindowClass`

### 2. Read current page state via vision
```text
mcp_cua_driver_get_window_state(capture_mode="vision", pid=..., window_id=...)
```
- **Critical:** Do NOT call SOM UIA walk for Firefox `MozillaWindowClass` — it times out after 4s.
- Vision capture returns a screenshot without UIA tree. Use this to inspect UI state.
- If UIA SOM walk is attempted, expect error: `get_window_state timed out after 4s (UIA provider unresponsive on hwnd ..., class 'MozillaWindowClass')`.

### 3. Focus the input field
```text
mcp_cua_driver_click(x=493, y=905, pid=15356, window_id=11470172, dispatch="background")
```
- These coordinates target the `cdk-textarea-autosize textarea` element in AI Studio's bottom input bar.
- This element exposes: `ValuePattern`, `InvokePattern`, `TextPattern`, `LegacyIAccessible`.
- **Why click instead of hotkey?**
  - `hotkey(["ctrl","a"], ...)` on `MozillaWindowClass` arrives as bare `a` because PostMessage does not set system modifier state.
  - Triple-click or direct pixel click is more reliable for selection/positioning.

### 4. Type the prompt
```text
mcp_cua_driver_type_text(text=..., pid=15356, window_id=11470172, dispatch="background")
```
- Uses `WM_CHAR` path; works reliably for text entry in MozillaWindowClass.
- Delay between characters: default 30ms. Adjust if autocomplete/IME is sensitive.
- This will overwrite or append depending on field state. If unsure, click field first (step 3).

### 5. Verify input landed
```text
mcp_cua_driver_get_window_state(capture_mode="vision", pid=..., window_id=...)
```
- Inspect screenshot to confirm text is present in the input area.
- If text is missing, re-focus the field and retry typing.

### 6. Send the message
- **Default: manual send.** User presses `Ctrl+Enter` in the focused input field.
- **Optional automation:**
  - Pixel-click the Run button using coordinates from vision zoom.
  - `hotkey(["ctrl","enter"], ...)` only after explicit user confirmation.

---

## 🚨 Known Issues and Workarounds

| Issue | Workaround |
|-------|-----------|
| `get_window_state` times out on Firefox | Use `capture_mode="vision"`; skip SOM UIA walk |
| `execute_javascript` unavailable in Firefox | Use CUA pixel/vision-based interactions; switch to Chrome with CDP if DOM needed |
| `hotkey(["ctrl","a"])` inserts literal "a" | Use click(x,y) to focus field instead |
| Firefox window is minimized/behind others | Use `list_windows` to find correct `window_id`; vision capture still works on minimized windows |
| Text input doesn't appear after `type_text` | Re-focus field with click(x,y); verify via vision screenshot |

---

## ✅ Verified Working Setup

- **OS:** Windows 10 x86_64
- **Firefox:** Mozilla Firefox (MozillaWindowClass)
- **cua-driver:** 0.6.8
- **Target app:** Google AI Studio (`aistudio.google.com`)
- **Input method:** `mcp_cua_driver_type_text` via PostMessage `WM_CHAR`
- **Focus method:** `mcp_cua_driver_click` at `(493, 905)` in window-local coordinates

---

## 📚 References

- cua-driver: `mcp_cua_driver_*` tools (list_windows, get_window_state, click, type_text, hotkey, zoom)
- Skill location (local): `C:\Users\tomekdot\AppData\Local\hermes\skills\software-development\computer-use-cua-firefox\SKILL.md`
- Skill location (repo): `https://github.com/tomekdot/hermes-skills/tree/main/skills/software-development/computer-use-cua-firefox`
- Related skill: `windows-desktop/computer-use-cua-firefox` (categorized under windows-desktop for generic CUA patterns)

---

## 🧪 Test Cases

### TC-1: Basic prompt entry
1. Call `list_windows(on_screen_only=true)` → confirm Firefox AI Studio window
2. Call `get_window_state(capture_mode="vision", ...)` → screenshot
3. `click(x=493, y=905)` on input field
4. `type_text("Hello from CUA test")`
5. `get_window_state(capture_mode="vision", ...)` → verify text visible
6. **Manual:** User presses Ctrl+Enter

### TC-2: Replace existing prompt
1. Focus input field with `click(x=493, y=905)`
2. `type_text("New prompt replacing old one")`
3. Verify via vision that old text is gone / replaced

### TC-3: Read AI response
1. Wait for AI response after manual send
2. `get_window_state(capture_mode="vision", ...)`
3. Inspect screenshot for response text in chat history

---

## ⚡ Quick Reference Card

| Step | Command | Notes |
|------|---------|-------|
| List windows | `list_windows(on_screen_only=true)` | Filter by `MozillaWindowClass` |
| Screenshot | `get_window_state(capture_mode="vision", pid, window_id)` | Fast, no UIA walk |
| Focus input | `click(x=493, y=905, pid, window_id)` | Targets textarea |
| Type prompt | `type_text(text, pid, window_id)` | WM_CHAR path |
| Verify | vision screenshot | Always verify after typing |
| Send (manual) | User presses Ctrl+Enter | Do not auto-send |

---

*Last updated: 2026-07-04 — verified working on cua-driver 0.6.8 + Firefox + Google AI Studio*
