---
name: openplanet-plugin-dev
description: "Create, debug, and structure Openplanet AngelScript plugins for Trackmania/Maniaplanet."
version: 1.5.0
author: Hermes Agent
license: MIT
platforms: [windows, linux, macos]
metadata:
  hermes:
    tags: [openplanet, trackmania, angelscript, plugin, game-modding]
---

# Openplanet Plugin Development

## Overview

Openplanet is a plugin/script development platform for Nadeo games (Trackmania 2020, Maniaplanet). Plugins are written in AngelScript (.as), a C++-like scripting language. This skill covers creating folder-based dev plugins, debugging compilation errors, and working around API quirks.

## Full API Documentation

The complete, up-to-date Openplanet API reference is available online:
**https://openplanet.dev/docs**

This includes all namespaces (UI, Time, IO, Net, Json, Math, nvg, etc.), function signatures, enums, and callback documentation. Always check the online docs for the latest API additions and changes.

## Project Layout

Two layouts exist:

### Folder-based (development) — PREFERRED
```
Openplanet4/Plugins/<plugin-name>/
├── info.toml          # Metadata (required)
├── Main.as            # Entry point (required)
├── src/               # Optional modules
│   ├── core/
│   ├── ui/
│   └── utils/
├── README.md
└── tests/             # Optional Python test scripts
```

All `.as` files in the folder are compiled together as a single module — no manual imports needed.

### Packaged (.op) — distribution
`.op` files are **ZIP archives**. Do NOT edit them directly — extract, develop as folder, re-zip for release.

## info.toml

```toml
[meta]
name = "My Plugin"
author = "yourname"
version = "1.0.0"
category = "Utility"

[script]
imports = []           # Scripts from Openplanet's Scripts/ folder
dependencies = []      # Other plugin identifiers
defines = []           # Preprocessor defines for dev
```

## Entry Points (callbacks)

| Function | When | Yieldable |
|----------|------|-----------|
| `void Main()` | Plugin starts | Yes |
| `void Render()` | Every frame (even with overlay closed) | No |
| `void RenderInterface()` | Every frame (overlay open only) | No |
| `void RenderMenu()` | Overlay menu items | No |
| `void Update(float dt)` | Every frame, dt in ms | No |
| `void OnEnabled()` / `void OnDisabled()` | Plugin toggled | No |
| `void OnDestroyed()` | Plugin unloaded | No |

## Settings

```angelscript
[Setting name="Display name" description="Tooltip"]
bool S_MySetting = true;

[Setting name="Slider value" min=0 max=100]
int S_Slider = 50;

[Setting hidden]
string S_InternalData = "";
```

## CRITICAL — API Quirks & Pitfalls

### 1. Time::Info uses PascalCase, NOT lowercase

**Error if wrong:** `'year' is not a member of 'Time::Info'`

| Correct | Wrong |
|---------|-------|
| `info.Year` | `info.year` |
| `info.Month` | `info.month` |
| `info.Day` | `info.day` |
| `info.Hour` | `info.hour` |
| `info.Minute` | `info.minute` |
| `info.Second` | `info.second` |

### 2. Weekday is NOT a member of Time::Info

`info.Weekday` will fail with `'Weekday' is not a member of 'Time::Info'`.

Use **Zeller's formula** (0=Sun..6=Sat) — inline array init `int t[] = {...}` does NOT work:

```angelscript
int GetDayOfWeek(int y, int m, int d) {
    if (m < 3) { m += 12; y -= 1; }
    int K = y % 100;
    int J = y / 100;
    int h = (d + (13 * (m + 1)) / 5 + K + K / 4 + J / 4 + 5 * J) % 7;
    return (h + 6) % 7; // 0=Sun
}
```

For converting from Unix timestamp directly:
```angelscript
int GetWeekdayFromUnix(uint64 unixTime) {
    uint64 daysSinceEpoch = unixTime / 86400;
    return int((daysSinceEpoch + 4) % 7); // 0=Sun..6=Sat (Jan 1 1970 = Thu = 4)
}
```

### 3. No UI::Font enum — use PushFontSize

**Error if wrong:** `No matching symbol 'UI::Font::OpenSansBold'`

```angelscript
// CORRECT:
UI::PushFontSize(22.0);
UI::Text("Big text");
UI::PopFontSize();

// WRONG (does not exist):
UI::PushFont(UI::Font::OpenSansBold);     // ERROR
UI::PushFont(UI::Font::DefaultBold);      // ERROR
```

### 4. No UI::TextColored — use PushStyleColor

**Error if wrong:** `No matching symbol 'UI::TextColored'`

```angelscript
// CORRECT:
UI::PushStyleColor(UI::Col::Text, vec4(0.3f, 1.0f, 0.5f, 1.0f));
UI::Text("Green text");
UI::PopStyleColor();

// WRONG:
UI::TextColored(color, "text");  // ERROR
```

### 5. Window position uses int coords

```angelscript
// CORRECT (cast floats to int):
UI::SetNextWindowPos(int(posX), int(posY), UI::Cond::Appearing);

// Triggers float-truncation warning:
UI::SetNextWindowPos(posX, posY, UI::Cond::Appearing);
```

### 6. UI::Begin takes a bool reference

```angelscript
bool S_WindowOpen = false;

// The bool ref lets the user close the window with X button:
if (!UI::Begin("My Window", S_WindowOpen, UI::WindowFlags::NoSavedSettings)) {
    UI::End();
    return;
}
```

### 7. Time functions

```angelscript
int64 now = Time::Stamp;                          // Epoch seconds
uint64 gameTime = Time::Now;                      // ms since game start
string formatted = Time::FormatString("%H:%M", now);  // strftime format
Time::Info info = Time::Parse(now);               // Local time
Time::Info utcInfo = Time::ParseUTC(stamp);       // UTC time
int64 parsed = Time::ParseFormatString("%Y-%m-%d %H:%M", "2026-05-26 20:00");
```

## Debugging Compilation Errors

1. **Check the log file** — errors appear in `Openplanet/Openplanet.log`
2. Look for `[ERROR]` lines with your plugin name
3. Common errors and their fixes:

| Error | Likely cause | Fix |
|-------|-------------|-----|
| `'xxx' is not a member of 'Time::Info'` | Wrong case | Use PascalCase: Year, Month, Day, etc. |
| `No matching symbol 'UI::Font::...'` | Font enum doesn't exist | Use PushFontSize/PopFontSize |
| `No matching symbol 'UI::TextColored'` | Function doesn't exist | Use PushStyleColor(UI::Col::Text, ...) |
| `Float value truncated in implicit conversion` | float where int expected | Cast: `int(value)` |
| `Signed/Unsigned mismatch` warning | Mixing `int` and `uint` in comparisons | Cast to match: `uint(idx)` or `int(arr.Length)` |
| `No matching signatures to 'UI::InputText(...)'` | Wrong param order (e.g. bufferSize as 3rd) | Use `bool&out changed` as 3rd param |
| `Expression must be of boolean type, instead found 'string'` | Using InputText return in `if()` | Call InputText separately, check `bool&out changed` after |
| `No matching function 'UI::SetNextWindowPos'` | Wrong param types | Pass int coords: `int(x), int(y)` |

**Reference files**

This skill ships with the official Openplanet API documentation as reference files. Load any of them when you need API details:

| File | Size | Contents |
|------|------|----------|
| `OpenPlanet-Global-API.md` | 73KB | Full global API reference (Time, UI, nvg, Net, IO, all namespaces) |
| `OpenPlanet-API-Reference.md` | 24KB | Complete API reference with all namespaces, enums, and function signatures |
| `Openplanet-Starter-API.md` | 60KB | Plugin development guide, callbacks, settings, icons |
| `OpenPlanet-Basic-API.md` | 42KB | Tutorials: NanoVG drawing, ImGui widgets, shapes, colors |
| `Openplanet-Changelog-API.md` | 16KB | Openplanet version history — what was added/changed/fixed |
| `plugin-skeleton.as` | 1.3KB | Minimal plugin template to start from |

### 8. Array initialization — inline `int t[] = {...}` fails inside functions

```angelscript
// WRONG — inline int array init does NOT work inside functions:
// int t[] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};  // ERROR: Expected '('

// CORRECT — use array<T> with InsertLast (dynamic):
array<int64> items;
items.InsertLast(123);

// CORRECT — pre-allocate at global scope using Resize():
int[] g_Array;
void Main() { g_Array.Resize(16); }

// CORRECT — inline array init works at global/namespace scope:
int[] monthDays = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
```

### 9. Recurring weekly events pattern

Common pattern for game schedules (COTD, Pursuit, etc.). Store day-of-week (1=Mon..7=Sun), hour, minute:

```angelscript
const int MAX_EVENTS = 16;
int g_Count = 0;
int[] g_WeekDay; int[] g_Hour; int[] g_Min; string[] g_Label;

void InitSchedule() {
    g_WeekDay.Resize(MAX_EVENTS); g_Hour.Resize(MAX_EVENTS);
    g_Min.Resize(MAX_EVENTS); g_Label.Resize(MAX_EVENTS);
    AddEvent(1, 18, 0, "Event name"); // Monday 18:00
}
void AddEvent(int d, int h, int m, const string &in l) {
    if (g_Count >= MAX_EVENTS) return;
    g_WeekDay[g_Count] = d; g_Hour[g_Count] = h;
    g_Min[g_Count] = m; g_Label[g_Count] = l; g_Count++;
}

int64 GetNextEventTs(int dayOfWeek, int hour, int minute) {
    int64 now = Time::Stamp;
    // diff = targetDOW - curDOW; if diff < 0 diff += 7
    // if diff == 0 && time passed: diff = 7
    // return todayStart + diff*86400 + hour*3600 + minute*60
}
```

### 10. Converting between Gregorian and lunar calendar dates

For custom calendars (e.g., 13-moon with 28-day months):

```angelscript
int GetDayOfYear(int year, int month, int day) { /* Gregorian DOY */ }
void DayOfYearToGregorian(int year, int dayOfYear, int &out month, int &out day);
uint64 UnixFromGregorian(int year, int month, int day);
void GetGregorianFromUnix(uint64 unixTime, int &out year, int &out month, int &out day);
```

### 11. Calendar day indicators (event dots / inline data)

**Event dots — mark days that have events:**
```angelscript
bool[] g_DaysWithEvents;
void Main() { g_DaysWithEvents.Resize(31); while (true) { RebuildEventDays(); yield(); } }

void RebuildEventDays() {
    for (int i = 0; i < 31; i++) g_DaysWithEvents[i] = false;
    int curDOW = (curWday == 0) ? 7 : curWday;
    for (int i = 0; i < g_EventCount; i++) {
        int diff = g_WeekDay[i] - curDOW;
        int64 eventDay = curDay + diff;
        if (eventDay >= 1 && eventDay <= 31) g_DaysWithEvents[eventDay - 1] = true;
    }
}
// In DrawCalendar:
if (g_DaysWithEvents[day - 1])
    UI::PushStyleColor(UI::Col::Button, vec4(0.4f, 0.8f, 0.4f, 0.25f));
```

**Inline data in each cell — show computed value without hover:**
```angelscript
// In each cell, after drawing the day number button:
UI::TextDisabled(Text::Format("%.0f", progress * 100.0));  // e.g. "23" = 23%%

// Moon phase icon alongside:
auto@ tex = Moon::GetTextureForPosition(synodic);
if (tex !is null) {
    UI::SameLine();
    UI::Image(tex, vec2(14, 14));
}
```

The inline percentage lets users see moon/sidereal cycle at a glance without mousing over each day. Combine with a tooltip for full details, and keep the inline text compact (2-3 chars: `"23"` not `"23.4%"`).

### 12. Upcoming events list with countdown

```angelscript
array<int64> eTs; array<string> eLabel; int64 now = Time::Stamp;
for (int i = 0; i < g_EventCount; i++) {
    int64 ets = GetNextEventTs(g_WeekDay[i], g_Hour[i], g_Min[i]);
    if (ets > now) { eTs.InsertLast(ets); eLabel.InsertLast(g_Label[i]); }
}
// Bubble sort
for (int a = 0; a < int(eTs.Length); a++)
    for (int b = a + 1; b < int(eTs.Length); b++)
        if (eTs[b] < eTs[a]) { /* swap */ }
// Display first 5
for (int i = 0; i < Math::Min(5, int(eTs.Length)); i++) {
    string ds = Time::FormatString("%a %H:%M", eTs[i]);
    if (i == 0) { UI::PushStyleColor(UI::Col::Text, vec4(0.3f, 1.0f, 0.5f, 1.0f)); }
    UI::Text((i==0?"> ":"  ") + eLabel[i] + " " + ds);
    if (i == 0) UI::PopStyleColor();
}
```

### 13. Config & Debug Window Pattern

When a plugin grows beyond a simple display, add a tabbed config+debug window:

```angelscript
void RenderDebugWindow() {
    UI::SetNextWindowSize(580, 520, UI::Cond::FirstUseEver);
    if (!UI::Begin("Config", g_ShowDebugWindow)) { UI::End(); return; }
    UI::BeginTabBar("Tabs");
    if (UI::BeginTabItem("Config")) { RenderConfigTab(); UI::EndTabItem(); }
    if (UI::BeginTabItem("Status")) { RenderStatusTab(); UI::EndTabItem(); }
    if (UI::BeginTabItem("History")) { RenderHistoryTab(); UI::EndTabItem(); }
    UI::EndTabBar(); UI::End();
}
```

**Config tab — toggle rows helper:**
```angelscript
void ConfigRow(const string &in label, bool value) {
    UI::TableNextRow();
    UI::TableSetColumnIndex(0); UI::Text(label);
    string s = value ? "ON" : "OFF";
    vec4 c = value ? vec4(0.3f, 1.0f, 0.4f, 1.0f) : vec4(0.6f, 0.6f, 0.6f, 1.0f);
    UI::TableSetColumnIndex(1);
    UI::PushStyleColor(UI::Col::Text, c); UI::Text(s); UI::PopStyleColor();
}
```

**Note:** `bool` is a primitive — pass by value, not `&inout`. See quirk #14 below.

**Status tab — live plugin state:**
```angelscript
void RenderStatusTab() {
    uint64 now = Time::get_Stamp();
    UI::Text("Unix: " + tostring(now));
    UI::Text("Today: " + format_string);
    UI::TextDisabled("Cached: " + tostring(g_Cache.GetKeys().Length));
    double val = Compute(now);
    UI::PushStyleColor(UI::Col::Text, GetColor(val));
    UI::Text("Phase: " + GetName(val));
    UI::PopStyleColor();
}
```

**Typical tab breakdown:**
| Tab | Content |
|-----|---------|
| Config | All `[Setting]` toggles in a table with ON/OFF |
| Status | Live values, cache queues, computed data |
| History | Data tables, map visits, recorded events |
| Reference | Static reference data (nodes, calibration tables) |

### 14. &inout on primitive types is NOT allowed

**Error if wrong:** `Only object types that support object handles can use &inout. Use &in or &out instead`

Primitive types (`bool`, `int`, `float`, `double`, `uint64`, etc.) cannot use `&inout` in function parameters — only object types (`string`, arrays, classes) can.

```angelscript
// WRONG:
void ConfigRow(const string &in label, bool &inout value) { }  // ERROR

// CORRECT — pass by value for reads:
void ConfigRow(const string &in label, bool value) { }

// CORRECT — use &out for write-only, &in for read-only references:
void SetResult(int &out result) { result = 42; }
void ProcessData(const string &in data) { }  // &in is fine for objects
```

### 15. UI::InputText — return type vs. bool&out changed

**Error if wrong:**
- `Expression must be of boolean type, instead found 'string'` — using return value directly in `if()`
- `No matching signatures to 'UI::InputText(...)'` — wrong parameter order

Openplanet has TWO overloads:

```angelscript
// Overload 1 — returns string, NO bool&out
string UI::InputText(const string&in label, string str,
    int flags = UI::InputTextFlags::None,
    UI::InputTextCallback@ callback = null);

// Overload 2 — bool&out changed as 3rd param, returns string
string UI::InputText(const string&in label, string str,
    bool&out changed,
    int flags = UI::InputTextFlags::None,
    UI::InputTextCallback@ callback = null);
```

**The trap:** `UI::InputText` ALWAYS returns `string`, even with the `bool&out` overload. You CANNOT use it directly in `if()`. Instead, call it then check the `changed` flag separately.

```angelscript
// WRONG — overload 1 returns string, can't use in if():
if (UI::InputText("##Input", g_Text, UI::InputTextFlags::EnterReturnsTrue)) { }  // ERROR

// WRONG — overload 2 ALSO returns string, bool&out doesn't change return type:
if (UI::InputText("##Input", g_Text, changed, UI::InputTextFlags::EnterReturnsTrue)) { }  // ERROR

// WRONG — bufferSize (int) as 3rd param doesn't match any overload:
UI::InputText("##Input", g_Text, 256, UI::InputTextFlags::EnterReturnsTrue);     // ERROR

// CORRECT — call InputText, then check changed separately:
bool changed = false;
UI::InputText("##Input", g_Text, changed, UI::InputTextFlags::EnterReturnsTrue);
if (changed) {
    // Enter was pressed
}
```

Note: `InputText` accepts `string` (not `string&`) for the text parameter — the callback or `changed` flag handles incremental updates. You don't need to pass `256` as bufferSize; the string grows dynamically.

### 16. string::IndexOf — takes exactly ONE parameter (no offset)

**Error if wrong:** `No matching signatures to 'string::IndexOf(const string, int)'`

`string::IndexOf` in Openplanet AngelScript takes **only one parameter** — the substring to find. There is NO second parameter for start offset (unlike C# or JavaScript).

```angelscript
// WRONG — IndexOf with 2 params (substring + offset) does NOT exist:
int idx = text.IndexOf("[", startPos);  // ERROR

// CORRECT — IndexOf with 1 param only:
int idx = text.IndexOf("[");  // Returns -1 if not found

// To search from a position, use SubStr first:
int idx = text.SubStr(startPos).IndexOf("[");
if (idx != -1) idx += startPos; // Adjust for the offset
```

Also note: `IndexOf` returns `int` (not `uint`), and returns `-1` when not found.

### 17. Text::Format takes exactly ONE value argument

**Error if wrong:** `No matching signatures to 'Text::Format(const string, double, double)'`

`Text::Format()` in Openplanet's AngelScript is NOT like C printf — it accepts **only one** value parameter, not variadic arguments:

```angelscript
// WRONG — multiple values in one call:
Text::Format("%.6f (%.2f%%)", sidereal, sidereal * 100.0);  // ERROR

// CORRECT — use two calls concatenated:
Text::Format("%.6f", sidereal) + " (" + Text::Format("%.2f%%", sidereal * 100.0) + ")";

// Single value works fine:
Text::Format("%.4f°", sidereal * 360.0);
Text::Format("%d items", count);
Text::Format("%.1f km/h", speed);
```
### 18. Signed/Unsigned mismatch warnings

**Warning:** `WARN : Signed/Unsigned mismatch` — appears when mixing `int` (signed) and `uint` (unsigned) in comparisons, assignments, or array indexing.

This is a WARNING, not an error — compilation succeeds, but indicates a potential logic bug.

```angelscript
// WARNING trigger examples:
uint length = arr.Length;    // arr.Length returns uint
int idx = someValue;
if (idx < length) { ... }    // int < uint → signed/unsigned mismatch warning

// CORRECT — cast to match types:
if (uint(idx) < length) { ... }
// or
int len = int(arr.Length);
if (idx < len) { ... }
```

Common places this appears: comparing loop counters against `array.Length` (which returns `uint`), or storing `uint` results in `int` variables. Fix by explicitly casting one side to match the other.

### 19. Preprocessor Directives

```angelscript
#if TMNEXT
    // Trackmania (2020) only
#elif MP4
    // Maniaplanet 4 only
#elif TURBO
    // Trackmania Turbo
#elif UNITED
    // Trackmania United
#endif

#if WINDOWS
    // Windows-specific code
#elif LINUX
    // Linux-specific code
#endif
```

### 20. Icons

Use `Icons::` namespace constants. Available icon families include FontAwesome (`Icons::Clock`, `Icons::Car`, `Icons::Info`, `Icons::Calendar`, `Icons::QuestionCircle`, `Icons::Crosshairs`, `Icons::Exclamation`, etc.) and Kenney (`Icons::Kenney::Plus`, `Icons::Kenney::Info`, etc.). Full list in the Starter API docs.

### 21. Per-window main-menu visibility

Use when a plugin exposes multiple windows from one menu and some should be hidden by default.
```angelscript
[Setting category="General" name="Show Calendar in Main Menu"]
bool S_ShowCalendarInMainMenu = true;

[Setting category="General" name="Show Player Profile in Main Menu"]
bool S_ShowPlayerProfileInMainMenu = true;
```

In `RenderMenuMain()` guard each item independently:
```angelscript
if (S_ShowCalendarInMainMenu) {
    if (UI::MenuItem(Icons::Star + "Apeiron Galaxy", "", g_UIState.ShowCalendarWindow)) {
        g_UIState.ShowCalendarWindow = !g_UIState.ShowCalendarWindow;
        S_ShowCalendarOnStart = g_UIState.ShowCalendarWindow;
    }
}
```

### 22. Cleaning up when removing a feature

Check EVERY `.as` file when removing feature from a multi-file plugin:

1. **Settings.as** — Remove setting toggle, event arrays, InitSchedule, helpers
2. **Core/Math files** — Remove calc functions (GetNextTs, HasEvent, etc.)
3. **UI files** — Remove rendering: dots, tooltip lines, event sections
4. **Diagnostics file** — Remove dead tab content and orphaned functions
5. **Main.as** — Remove InitSchedule() call

Use `grep -rn "DeletedName" Plugins/<name>/` before deleting to catch all references.

---

## Openplanet Folder Structure Reference

### Root layout
```
Openplanet4/
├── docs/                  # API documentation (Markdown + .h)
├── Plugins/               # Your installed/developed plugins
├── Plugins-Archive/       # Disabled/old plugins
├── Plugins-Developer/     # WIP/dev copies
├── Plugins-Downloaded/    # Downloaded .op files (ZIP archives)
├── PluginStorage/         # Per-plugin persistent data
├── Openplanet/            # Openplanet's runtime files
├── Scripts/               # User scripts (survives updates)
├── ManiaScript/           # ManiaScript libraries
├── Settings.ini           # Openplanet-wide settings
├── Gui.ini                # ImGui window positions/sizes
├── Openplanet.log         # Debug log — check for compilation errors
├── Openplanet.h           # C++ game class hierarchy
├── Openplanet4.json       # Plugin registry metadata
└── OpenplanetCore.json    # Built-in plugin metadata
```

### Openplanet/ runtime files
```
Scripts/     — Built-in imports (Dialogs.as, Patch.as, etc.)
Plugins/     — System plugins (VehicleState, Camera, Controls, Discord)
Fonts/       — DroidSans*, Montserrat*, Oswald*, ManiaIcons.ttf
```

**⚠️ Never put scripts in `Openplanet/Scripts/` — deleted on update. Use `Openplanet4/Scripts/`.**

### Plugin dependencies in info.toml
```toml
[script]
dependencies = [ "VehicleState" ]  # Also: Camera, Controls, Discord
imports = [ "Dialogs.as", "Patch.as" ]
```

### Reference files

Full list of these reference files with API details, patterns, and debugging tips you can find in the website on: https://github.com/tomekdot/hermes-skills/tree/main/skills/gaming/openplanet-plugin-dev/references
These are also included in the skill package for offline access.

| File | Size | Contents |
|------|------|----------|
| `OpenPlanet-Global-API.md` | 73KB | Full global API ref (Time, UI, nvg, Net, IO) |
| `Openplanet-Starter-API.md` | 60KB | Plugin dev guide, callbacks, settings, icons |
| `OpenPlanet-Basic-API.md` | 42KB | Tutorials: NanoVG, ImGui, shapes, colors |
| `Openplanet-Changelog-API.md` | 16KB | Version history |
| `plugin-skeleton.as` | 1.3KB | Minimal plugin template |
| `info-toml-reference.md` | 4KB | Full info.toml field reference |
| `time-api.md` | 2KB | Time API quick reference (Parse, FormatString, weekday) |
| `maniaplanet-feedback-extraction.md` | 3KB | Parsing ManiaPlanet Feedback HTML (ratings, vote counts) |
| `ui-window-template.as` | 1KB | Boilerplate UI window template |


## Verification

After creating or modifying a plugin:

1. Restart Trackmania/Openplanet (or disable/re-enable the plugin in settings)
2. Check Openplanet overlay menu for the plugin's menu item
3. Check `Openplanet.log` for any compilation errors (the log includes line numbers)
4. Settings appear under Openplanet Settings → plugin name
5. For UI changes: toggle the window open/close to verify rendering

