---
name: openplanet-plugin-dev
description: "Create, debug, and structure Openplanet AngelScript plugins for Trackmania/Maniaplanet."
version: 1.0.0
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
| `No matching function 'UI::SetNextWindowPos'` | Wrong param types | Pass int coords: `int(x), int(y)` |

### Reference files

This skill ships with the official Openplanet API documentation as reference files. Load any of them when you need API details:

| File | Size | Contents |
|------|------|----------|
| `OpenPlanet-Global-API.md` | 73KB | Full global API reference (Time, UI, nvg, Net, IO, all namespaces) |
| `Openplanet-Starter-API.md` | 60KB | Plugin development guide, callbacks, settings, icons |
| `OpenPlanet-Basic-API.md` | 42KB | Tutorials: NanoVG drawing, ImGui widgets, shapes, colors |
| `Openplanet-Changelog-API.md` | 16KB | Openplanet version history — what was added/changed/fixed |
| `plugin-skeleton.as` | 1.3KB | Minimal plugin template to start from |

Usage:
```angelscript
[skill openplanet-plugin-dev]
[load reference OpenPlanet-Global-API.md]
```

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
    // ...
}
void AddEvent(int d, int h, int m, const string &in l) {
    if (g_Count >= MAX_EVENTS) return;
    g_WeekDay[g_Count] = d; g_Hour[g_Count] = h;
    g_Min[g_Count] = m; g_Label[g_Count] = l; g_Count++;
}

int64 GetNextEventTs(int dayOfWeek, int hour, int minute) {
    int64 now = Time::Stamp;
    int gregYear, gregMonth, gregDay;
    // Convert to Gregorian, compute weekday diff (see GetWeekdayFromUnix)
    // diff = targetDOW - curDOW; if diff < 0 diff += 7
    // if diff == 0 && time passed: diff = 7
    // return todayStart + diff*86400 + hour*3600 + minute*60
}
```

### 10. Converting between Gregorian and calendar dates

For custom calendars (e.g., 13-moon lunar calendar with 28-day months):

```angelscript
int GetDayOfYear(int year, int month, int day) { /* standard Gregorian DOY */ }
void DayOfYearToGregorian(int year, int dayOfYear, int &out month, int &out day) { /* reverse */ }
uint64 UnixFromGregorian(int year, int month, int day);
void GetGregorianFromUnix(uint64 unixTime, int &out year, int &out month, int &out day);
```

### 11. Calendar day indicators (event dots)

When showing recurring events on a calendar grid, maintain a `bool[]` array (size 31) marking which days have events. Rebuild it each frame:

```angelscript
bool[] g_DaysWithEvents;
void Main() { g_DaysWithEvents.Resize(31); while (true) { RebuildEventDays(); yield(); } }

void RebuildEventDays() {
    for (int i = 0; i < 31; i++) g_DaysWithEvents[i] = false;
    // curWday = GetDayOfWeek(curYear, curMonth, curDay); // 0=Sun..6=Sat
    int curDOW = (curWday == 0) ? 7 : curWday; // convert to 1=Mon..7=Sun
    for (int i = 0; i < g_EventCount; i++) {
        int diff = g_WeekDay[i] - curDOW;
        int64 eventDay = curDay + diff;
        if (eventDay >= 1 && eventDay <= 31) g_DaysWithEvents[eventDay - 1] = true;
    }
}

// In DrawCalendar, tint cells that have events:
bool hasEvent = g_DaysWithEvents[day - 1];
if (hasEvent) {
    UI::PushStyleColor(UI::Col::Button, vec4(0.4f, 0.8f, 0.4f, 0.25f));
} else if (isToday) {
    UI::PushStyleColor(UI::Col::Button, vec4(0.2f, 0.5f, 1.0f, 0.6f));
}
```

For a compact green dot next to a day number (when the cell already has a moon icon, etc.):

```angelscript
UI::BeginGroup();
UI::Button(dayLabel, vec2(-1, btnH));
if (HasEventOnDay(...)) {
    UI::SameLine();
    UI::PushStyleColor(UI::Col::Text, vec4(0.3f, 1.0f, 0.4f, 0.9f));
    UI::Text(".");
    UI::PopStyleColor();
}
// ... moon icon ...
UI::EndGroup();
```

Also enhance tooltips for event days:

```angelscript
if (UI::IsItemHovered()) {
    UI::BeginTooltip();
    // ... existing content ...
    if (HasEventOnDay(...)) {
        UI::Separator();
        UI::PushStyleColor(UI::Col::Text, vec4(0.3f, 1.0f, 0.4f, 1.0f));
        UI::Text("Event today!");
        UI::PopStyleColor();
    }
    UI::EndTooltip();
}
```

### 12. Upcoming events list with countdown

After the calendar grid, show the next N recurring events sorted by time. Use `array<int64>` at function scope — it works:

```angelscript
array<int64> eTs;
array<string> eLabel;
int64 now = Time::Stamp;

for (int i = 0; i < g_EventCount; i++) {
    int64 ets = GetNextEventTs(g_WeekDay[i], g_Hour[i], g_Min[i]);
    if (ets > now) { eTs.InsertLast(ets); eLabel.InsertLast(g_Label[i]); }
}

// Bubble sort ascending
for (int a = 0; a < int(eTs.Length); a++)
    for (int b = a + 1; b < int(eTs.Length); b++)
        if (eTs[b] < eTs[a]) {
            int64 t = eTs[a]; eTs[a] = eTs[b]; eTs[b] = t;
            string l = eLabel[a]; eLabel[a] = eLabel[b]; eLabel[b] = l;
        }

int showCount = Math::Min(5, int(eTs.Length));
for (int i = 0; i < showCount; i++) {
    string ds = Time::FormatString("%a %H:%M", eTs[i]);
    if (i == 0) { // next — green
        UI::PushStyleColor(UI::Col::Text, vec4(0.3f, 1.0f, 0.5f, 1.0f));
        UI::Text("> " + eLabel[i] + " " + ds);
        UI::PopStyleColor();
    } else {
        UI::Text("  " + eLabel[i] + " " + ds);
    }
}

// Countdown
int64 diffSec = eTs[0] - now;
int days = int(diffSec / 86400);
int hours = int((diffSec % 86400) / 3600);
int mins = int((diffSec % 3600) / 60);
UI::TextDisabled("Next in: " + tostring(days) + "d " + Fmt2(hours) + "h " + Fmt2(mins) + "m");
```

### 13. Adding features to existing multi-file plugins

When modifying a plugin with multiple `.as` source files, changes typically span 4 files:

| File | What to add |
|------|-------------|
| `src/config/Settings.as` | Event arrays + `InitSchedule()` + setting toggle bool |
| `src/core/CalendarMath.as` | `GetWeekdayFromUnix()`, `GetNextEventTs()`, `HasEventOnDate()` |
| `src/ui/CalendarWindow.as` | Green dots in grid, tooltip enhancement, upcoming events section |
| `Main.as` | Call `InitSchedule()` before the main loop |

Helper functions go in CalendarMath. Settings toggle goes in Settings.as so user can disable the feature in Openplanet settings UI. UI rendering stays in the UI file.

---

## Openplanet Folder Structure Reference

The `Openplanet4/` folder contains everything Openplanet needs to run. Knowing what lives where saves time when debugging or extending plugins.

### Root layout

```
Openplanet4/
├── docs/                  # API documentation (Markdown + .h headers)
├── Plugins/               # Your installed/developed plugins (folder-based or .op)
├── Plugins-Archive/       # Disabled/old plugins
├── Plugins-Developer/     # WIP/dev plugin copies
├── Plugins-Downloaded/    # Downloaded .op files (ZIPs)
├── PluginStorage/         # Per-plugin persistent data files
├── Openplanet/            # Openplanet's own runtime files
├── IX/                    # Internal scripts (empty unless extracted)
├── Scripts/               # User scripts (not cleared on update)
├── ManiaScript/           # ManiaScript libraries
├── lib/                   # Native DLLs
├── Settings.ini           # Openplanet settings (not plugin settings)
├── Gui.ini                # Window positions & sizes for built-in windows
├── Openplanet.log         # Debug log — check here for compilation errors
├── Openplanet.h           # Full C++ class hierarchy for the game engine
├── Openplanet4.json       # Openplanet plugin registry metadata
└── OpenplanetCore.json    # Core plugin metadata (built-in plugins)
```

### Openplanet/ — Runtime files

```
Openplanet/
├── Scripts/               # Built-in scripts you can import in info.toml
│   ├── Compatibility.as   # Compatibility helpers
│   ├── Dialogs.as         # Simple dialog rendering framework
│   ├── Patch.as           # Memory patching helpers
│   ├── Plugin_BigDecor.as # Big decor placement
│   ├── Plugin_EditorDeveloper.as  # Editor development tools
│   ├── Plugin_HelloWorld.as       # Example plugin
│   ├── Plugin_InfiniteEmbedSize.as
│   ├── Plugin_MapTools.as
│   └── Plugin_StadiumUnlock.as
├── Plugins/               # Built-in system plugins (loaded by Openplanet)
│   ├── Camera/            # Camera control plugin dependency
│   ├── Controls/          # Input control system
│   ├── Discord/           # Discord Rich Presence integration
│   ├── Finetuner/         # Advanced settings tuning
│   ├── PluginManager/     # Plugin management UI
│   ├── UsefulInformation/ # In-game info overlay
│   └── VehicleState/      # Vehicle telemetry API (important for car plugins!)
├── Fonts/                 # Available fonts (use in UI::PushFont)
│   ├── DroidSans.ttf / DroidSans-Bold.ttf
│   ├── DroidSansMono.ttf
│   ├── ManiaIcons.ttf     # Icon font (Icons:: namespace)
│   ├── Montserrat.ttf / Montserrat-Bold.ttf
│   ├── Oswald.ttf / Oswald-Bold.ttf
├── DefaultStyle.toml      # Default UI style values
├── cacert.pem             # SSL certificates for HTTPS requests
└── READ_ME.txt            # Warning: don't put your scripts here!
```

**⚠️ IMPORTANT:** Never put custom scripts in `Openplanet/Scripts/` — they get **deleted on update**. Use `Openplanet4/Scripts/` instead (your user data folder).

### Key config files

| File | Description |
|------|-------------|
| `Settings.ini` | Openplanet-wide settings (not per-plugin). Includes window positions, enabled/disabled plugins, etc. |
| `Gui.ini` | Saves window sizes/positions of ImGui windows. Deleting this resets all window layouts. |
| `Openplanet4.json` | Plugin registry — metadata about all installed plugins, their versions, signature info. |
| `OpenplanetCore.json` | Same as above but for built-in system plugins. |
| `Openplanet.h` | The C++ header defining the complete game class hierarchy. Not directly usable in AngelScript but useful for finding property names (e.g., `VehicleState::ViewingPlayerState().FrontSpeed`). |

### Plugin dependencies (built-in)

These are available as `[script] dependencies` in `info.toml`:

```toml
[script]
dependencies = [ "VehicleState" ]  # Car physics API
# Also available: Camera, Controls, Discord
```

The source for these is in `Openplanet/Plugins/<Name>/`. Study them to understand the API.

### Fonts in UI

```angelscript
// These font files are in Openplanet/Fonts/ and can be loaded:
UI::PushFont("DroidSans", 16.0);
UI::PushFont("Montserrat-Bold", 18.0);
UI::PushFont("Oswald", 14.0);
// Don't forget:
UI::PopFont();
```

### Scripts available for import

In `info.toml`:
```toml
[script]
imports = [ "Dialogs.as", "Patch.as" ]
```

These live in `Openplanet/Scripts/` and are compiled into your plugin at load time. Each has a `.as.sig` signature file for integrity checking.