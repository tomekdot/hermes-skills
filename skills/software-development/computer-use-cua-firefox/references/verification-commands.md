# 🔧 Verification Commands & CUA Tools Log

This file documents every terminal command and CUA/browser tool call used to verify, test, and publish the `computer-use-cua-firefox` skill.

---

## 1. Environment & Driver Checks

- `mcp_cua_driver_health_report(...)` — check cua-driver installation and permissions
- `mcp_cua_driver_list_apps()` — list all running/installed apps; Firefox must appear here
- `mcp_cua_driver_list_windows(on_screen_only=true)` — list Windows with on-screen filter
- `mcp_cua_driver_list_windows(pid=15356)` — find Firefox AI Studio window specifically
  - Output: `firefox.exe (pid 15356) "Powitanie I Oferta Pomocy | Google AI Studio — Mozilla Firefox" [window_id: 11470172]`
  - Window class: `MozillaWindowClass`

---

## 2. Skill Creation & Metadata

- `skill_view(name="openplanet-plugin-dev")` — view existing skill schema for reference
- `skill_view(name="software-development/computer-use-cua-firefox")` — inspect created skill
- `write_file(path="C:\\Users\\tomekdot\\AppData\\Local\\hermes\\skills\\software-development\\computer-use-cua-firefox\\SKILL.md", content="...")` — create/update the skill file locally

---

## 3. File Operations (local + repo)

- `mkdir -p C:/Users/tomekdot/hermes-skills/skills/software-development/computer-use-cua-firefox` — create directories
- `mv C:/Users/tomekdot/hermes-skills/skills/computer-use-cua-firefox/SKILL.md C:/Users/tomekdot/hermes-skills/skills/software-development/computer-use-cua-firefox/SKILL.md` — move from old location to new category
- `cp -r C:/Users/tomekdot/hermes-skills/skills/software-development/computer-use-cua-firefox C:/Users/tomekdot/AppData/Local/hermes/skills/software-development/computer-use-cua-firefox` — sync to local Hermes skills dir
- `find C:/Users/tomekdot/hermes-skills/skills -maxdepth 3 -name SKILL.md | sort` — verify structure
- `find C:/Users/tomekdot/AppData/Local/hermes/skills -maxdepth 3 -name SKILL.md | sort` — verify local skills

---

## 4. Git Workflow (tomekdot/hermes-skills)

- `git -C C:/Users/tomekdot/hermes-skills status -sb` — check repo status
- `git -C C:/Users/tomekdot/hermes-skills remote -v` — check remotes
- `git -C C:/Users/tomekdot/hermes-skills log --oneline -n 3` — recent commits
- `git -C C:/Users/tomekdot/hermes-skills add <paths>` — stage changes
- `git -C C:/Users/tomekdot/hermes-skills commit -m "..."` — commit
- `git -C C:/Users/tomekdot/hermes-skills push origin main` — push to GitHub

**Commits made during this session:**
- `6d1ba93` Add CUA Firefox + AI Studio automation skill under software-development
- `af47624` Move CUA Firefox skill to software-development and update workflow
- `f8bc763` Update CUA Firefox skill: full tested workflow, references, test cases

---

## 5. CUA Testing Workflow (end-to-end)

**Step 1: Focus Firefox AI Studio window**
- `mcp_cua_driver_list_windows(on_screen_only=true)`
- Confirmed: `pid=15356, window_id=11470172`

**Step 2: Screenshot via vision (avoid UIA timeout)**
- `mcp_cua_driver_get_window_state(capture_mode="vision", pid=15356, window_id=11470172)`
- Critical: Do NOT call SOM UIA walk for Firefox `MozillaWindowClass` — it times out after 4s.

**Step 3: Focus the input textarea**
- `mcp_cua_driver_click(x=493, y=905, pid=15356, window_id=11470172, dispatch="background")`
- UIA result: `Performed UIA Invoke at (1454,906) for pid 15356`
- Element: `cdk-textarea-autosize textarea ng-valid ng-touched ng-dirty (control_type_id=50004)`

**Step 4: Type the prompt**
- `mcp_cua_driver_type_text(text="Test: czy wpisywanie przez CUA działa w AI Studio na Firefox?", pid=15356, window_id=11470172, dispatch="background")`
- Result: `Typed 61 char(s) via PostMessage WM_CHAR (30ms delay)`

**Step 5: Verify text landed (vision only)**
- `mcp_cua_driver_get_window_state(capture_mode="vision", pid=15356, window_id=11470172)`
- `vision_analyze(image_url="...", question="Is test prompt visible in input?")`
- Result: `Yes, text says exactly: "Test: czy wpisywanie przez CUA działa w AI Studio na Firefox?"`

**Step 6: Manual send by user (Ctrl+Enter) — NOT automated**

---

## 6. Browser / Navigation

- `browser_navigate(url="https://github.com/tomekdot/hermes-skills/tree/main/skills")` — open GitHub repo page
- `browser_snapshot(full=true)` — read DOM/accessibility tree
- `read_file(path="C:\\Users\\tomekdot\\hermes-skills\\README.md", limit=200)` — read README

---

## 7. Tools Reference

| Tool | Used For | Key Parameters |
|------|----------|----------------|
| `mcp_cua_driver_list_windows` | Find Firefox window | `on_screen_only=true`, `pid=15356` |
| `mcp_cua_driver_get_window_state` | Screenshot / UIA tree | `capture_mode="vision"`, `pid`, `window_id` |
| `mcp_cua_driver_click` | Focus textarea / UI interaction | `x=493, y=905`, `pid=15356`, `dispatch="background"` |
| `mcp_cua_driver_type_text` | Type prompt via WM_CHAR | `text=...`, `pid=15356`, `window_id=11470172` |
| `mcp_cua_driver_hotkey` | Keyboard shortcuts | `keys=["ctrl","enter"]`, `pid=15356` |
| `mcp_cua_driver_zoom` | Zoom into Run button region | `x1,x2,y1,y2`, `pid`, `window_id` |
| `mcp_cua_driver_debug_window_info` | Inspect UIA focused element | `pid=15356` |
| `mcp_cua_driver_health_report` | Driver diagnostics | None |
| `mcp_cua_driver_list_apps` | List installed/running apps | None |
| `browser_navigate` | Open web pages | `url=...` |
| `browser_snapshot` | Read DOM / accessibility tree | `full=true` |
| `read_file` | Read local files | `path`, `limit`, `offset` |
| `write_file` | Create/overwrite files | `path`, `content` |
| `patch` | Targeted file edits | `mode="replace"`, `path`, `old_string`, `new_string` |
| `terminal` | Shell commands | `command`, `timeout`, `workdir` |
| `vision_analyze` | Inspect screenshots | `image_url`, `question` |
| `skill_view` | Read skill metadata/content | `name=...` |

---

## 8. Reproducible Test Sequence (copy-paste ready)

```
1. mcp_cua_driver_list_windows(on_screen_only=true)
2. mcp_cua_driver_get_window_state(capture_mode="vision", pid=15356, window_id=11470172)
3. mcp_cua_driver_click(x=493, y=905, pid=15356, window_id=11470172, dispatch="background")
4. mcp_cua_driver_type_text(text="YOUR_PROMPT_HERE", pid=15356, window_id=11470172, dispatch="background")
5. mcp_cua_driver_get_window_state(capture_mode="vision", pid=15356, window_id=11470172)
6. [User manually presses Ctrl+Enter]
```

---

## 9. Paths

| Resource | Path |
|----------|------|
| Skill SKILL.md (local) | `C:\Users\tomekdot\AppData\Local\hermes\skills\software-development\computer-use-cua-firefox\SKILL.md` |
| Skill SKILL.md (repo) | `C:\Users\tomekdot\hermes-skills\skills\software-development\computer-use-cua-firefox\SKILL.md` |
| Verification log | `C:\Users\tomekdot\hermes-skills\skills\software-development\computer-use-cua-firefox\references\verification-commands.md` |
| GitHub repo | https://github.com/tomekdot/hermes-skills/tree/main/skills/software-development/computer-use-cua-firefox |

---

*Last updated: 2026-07-04*
