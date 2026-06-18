# info.toml Reference

The `info.toml` file specifies metadata for an Openplanet plugin. Format: [TOML](https://toml.io/en/latest).

## [meta] table (Required)

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `name` | String | Recommended | Display name of the plugin |
| `author` | String | Recommended | Plugin author |
| `version` | String | Yes | Version string, required for website submission |
| `category` | String | Recommended | Grouping category (e.g. "Utility", "Galaxy", "GUI") |
| `siteid` | Integer | No | Auto-added during plugin review |
| `blocks` | String[] | No | Plugin identifiers to block (e.g., block old versions) |
| `perms` | String | Deprecated | Use Permissions API instead (`free`, `paid`, `full`) |

## [game] table (Optional)

| Key | Type | Description |
|-----|------|-------------|
| `min_version` | String | Minimum game build date: `"2022-02-03"` or `"2022-02-03 18:03"` |
| `max_version` | String | Maximum game build date (same format) |

## [script] table (Optional)

| Key | Type | Description |
|-----|------|-------------|
| `timeout` | Integer | Callback execution timeout in ms. `0` = disabled (no infinite-loop protection) |
| `imports` | String[] | Script files from `Openplanet/Scripts/` to include (e.g., `["Dialogs.as"]`) |
| `exports` | String[] | Files to export to dependent plugins (compiled into dependents, not self) |
| `shared_exports` | String[] | Like exports, but also compiled into this plugin |
| `dependencies` | String[] | Required plugin UIDs (e.g., `["VehicleState"]`). Plugin won't load if missing |
| `export_dependencies` | String[] | Dependencies to also export to any plugin depending on this one |
| `optional_dependencies` | String[] | Optional plugin UIDs — plugin loads without them, no compile error |
| `defines` | String[] | Preprocessor defines (e.g., `["DEBUG"]`) |
| `module` | String | Force a specific module name (defaults to plugin identifier) |

## Minimal Example

```toml
[meta]
name = "Minimal Plugin"
author = "tomekdot"
version = "1.0.0"
category = "Utility"
```

## Full Example

```toml
[meta]
name = "Calendar & Events"
author = "tomekdot"
version = "1.0.0"
category = "Utility"

[game]
min_version = "2023-01-01"

[script]
timeout = 5000
defines = ["BETA"]
```
