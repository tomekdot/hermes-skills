# Openplanet Time API Reference

Namespace: `Time`

## Properties

```
uint64 Time::Now        → Milliseconds since game started
int64  Time::Stamp      → Unix epoch timestamp in SECONDS
uint64 Time::FrameCount → Number of frames Openplanet has processed
```

## Time::Info Structure

Returned by `Time::Parse()` and `Time::ParseUTC()`. Fields:

| Field | Type | Description |
|-------|------|-------------|
| `year` | int | Full year (e.g., 2025) |
| `month` | int | 1-12 |
| `day` | int | 1-31 |
| `hour` | int | 0-23 |
| `minute` | int | 0-59 |
| `second` | int | 0-59 |
| `weekday` | int | 0=Sunday, 1=Monday, ..., 6=Saturday |
| `yearday` | int | 0-365 (day of year) |

## Functions

### Format string (strftime)

```angelscript
string Time::FormatString(const string&in format, int64 stamp = -1)
string Time::FormatStringUTC(const string&in format, int64 stamp = -1)
```

| Specifier | Output (example) |
|-----------|-----------------|
| `%Y` | 2025 |
| `%m` | 05 |
| `%d` | 26 |
| `%H` | 14 (24h) |
| `%I` | 02 (12h) |
| `%M` | 30 |
| `%S` | 45 |
| `%p` | AM/PM |
| `%A` | Monday (full weekday) |
| `%a` | Mon (abbreviated weekday) |
| `%B` | January (full month) |
| `%b` | Jan (abbreviated month) |
| `%c` | Mon May 26 14:30:45 2025 |
| `%x` | 05/26/2025 |
| `%X` | 14:30:45 |
| `%j` | 146 (day of year) |
| `%w` | 1 (weekday, 0=Sunday) |
| `%u` | 1 (weekday, 1=Monday) |

`stamp = -1` defaults to current time.

### Parse string to timestamp

```angelscript
int64 Time::ParseFormatString(const string&in format, const string&in stamp)
```

### Parse timestamp to Info

```angelscript
Time::Info Time::Parse(int64 stamp = -1)       // local time
Time::Info Time::ParseUTC(int64 stamp = -1)    // UTC
```

### Game time formatting

```angelscript
string Time::Format(uint64 time, bool fractions = true, bool forceMinutes = true, bool forceHours = false, bool short = false)
```

Formats game milliseconds to race time. Example: `Time::Format(61234)` → `"1:01.234"`.

## Common Patterns

```angelscript
// Current time as string
string now = Time::FormatString("%H:%M:%S", Time::Stamp);

// Today's date
string today = Time::FormatString("%Y-%m-%d", Time::Stamp);

// Parse an event date
int64 eventTs = Time::ParseFormatString("%Y-%m-%d %H:%M", "2025-06-01 18:00");

// Check if event is in the future
if (eventTs > Time::Stamp) { ... }

// Days until event
int64 diffSec = eventTs - Time::Stamp;
int days = int(diffSec / 86400);
int hours = int((diffSec % 86400) / 3600);
int minutes = int((diffSec % 3600) / 60);
```
