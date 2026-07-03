---
name: computer-use-cua-firefox
description: Reliable patterns for driving Firefox in AI Studio / Gemini through cua-driver on Windows. Use when browser automation must enter prompts into AI Studio, read back replies, or click Run/Send from the bottom input bar.
version: 0.1.0
metadata:
  hermes:
    tags: [computer-use, firefox, ai-studio, cua-driver, windows, automation]
---

# 🖥️ CUA Firefox + AI Studio Automation

## 📋 Overview

Firefox on Windows is **not safely queryable by UIA `get_window_state`** for complex pages like Google AI Studio. This skill encodes the proven fallback sequence.

Use this when the task is:
- Type a prompt into Google AI Studio in Firefox
- Read back the current AI Studio conversation via vision
- Click Run / Send from the bottom input bar

## 🔁 Canonical Workflow

1. **Find the Firefox window**
   - `mcp_cua_driver_list_windows(on_screen_only=true)`
   - filter by title containing `Mozilla Firefox` or `Google AI Studio`

2. **Read the page via vision**
   - `mcp_cua_driver_get_window_state(capture_mode="vision", pid=..., window_id=...)`
   - If needed: `mcp_cua_driver_zoom(...)` for the input area

3. **Focus + replace text**
   - `mcp_cua_driver_hotkey(keys=["ctrl","a"], ...)`
   - `mcp_cua_driver_type_text(...)` with the full prompt

4. **Send**
   - Either click Run via zoom/click
   - Or hotkey `Ctrl+Enter`

## 🚨 Firefox Limitations
- `get_window_state` usually times out on Firefox (`MozillaWindowClass`)
- `execute_javascript` fails unless Chrome `--remote-debugging-port` is used
- DOM queries are best-effort; prefer vision snapshots

## ✅ Exceptions
If `execute_javascript` becomes available in Firefox via future driver update, prefer DOM selectors over vision.
