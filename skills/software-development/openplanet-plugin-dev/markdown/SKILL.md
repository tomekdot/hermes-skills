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
    return int((daysSinceEpoch + 3) % 7); // 0=Sun..6=Sat
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