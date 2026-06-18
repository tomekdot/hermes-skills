---
name: pursuit-maps
description: "TrackMania Pursuit maps from ManiaPlanet Feedback display/106 - Season 1 Episode 1 by Dommy. 248 map thumbnails with UIDs."
version: 1.1.0
author: OWL
tags: ["trackmania", "pursuit", "maniaplanet", "maps", "thumbnails"]
---

# Pursuit Maps - ManiaPlanet Feedback S1 E1

Thumbnails and UID data for 249 maps from ManiaPlanet Feedback display/106 (TrackMania² Pursuit Multi-environment Season 1 Episode 1 by Dommy).

## Folder Structure

```
pursuit-maps/
├── SKILL.md
└── assets/
    └── thumbnails/
        └── {UID}.jpg   (248 files, one per map)
```

## Data Sources

- **Feedback page**: https://feedback.prod.live.maniaplanet.com/votes/display/106
- **Google Sheets**: https://docs.google.com/spreadsheets/d/1PwcF1PXHnYhyE23-VPqHewkD_lcNMPIg7LXDN_NaVHQ/edit#gid=763170857

## File Naming Convention

Each thumbnail is named `{UID}.jpg` where UID is the unique ManiaPlanet map identifier.

Example: `pdHcfgrPuzYKYG84amT6KREpj97.jpg` → `[Pursuit] - Third Contribution`

## Map URL Patterns

- Thumbnail: `https://files-v4.live.maniaplanet.com/maps/{hash}/{UID}.jpg`
- Feedback: `https://feedback.prod.live.maniaplanet.com/votes/display/106`

Note: The `{hash}` in the thumbnail URL varies per map and is NOT the same as the UID. The UID is unique per map.

## Missing File

1 file could not be downloaded (HTTP 403):
- `xmPnj0qC1jmfw64X53VjWNXfpj.jpg` (Liminal Maze Tower by piotrunio)

## Scripts

| Script | Description |
|--------|-------------|
| `scripts/download_thumbnails.py` | Download map thumbnails from ManiaPlanet |
| `scripts/read_sheets.py` | Read Google Sheets via gviz API |
| `scripts/pursuit_maps_generator.py` | Generate markdown table from Sheets data |
| `scripts/enrich_with_mx.py` | Enrich CSV with ManiaExchange API data |

### pursuit_maps_generator.py
Generates a complete markdown document from Google Sheets data:
- Summary stats by environment and map type
- Full map table with all metadata
- Author statistics
- UID reference list

```bash
python3 scripts/pursuit_maps_generator.py --with-thumbnails assets/thumbnails
```

### enrich_with_mx.py
Queries ManiaExchange API (`https://tm.mania.exchange/api/maps/get_map_info/id/{UID}`)
for each map in the CSV and adds 17 new columns:
- MX TrackID, MX Name, MX GbxMapName, MX AuthorLogin
- MX MapType, MX TitlePack, MX EnvironmentName, MX VehicleName
- MX DifficultyName, MX LengthName, MX UploadedAt, MX UpdatedAt
- MX Downloadable, MX Comments, MX AwardCount
- MX HasThumbnail, MX HasScreenshot

```bash
python3 scripts/enrich_with_mx.py --dry-run          # preview
python3 scripts/enrich_with_mx.py                     # writes to CSV (creates .bak)
python3 scripts/enrich_with_mx.py --delay 0.5         # slower rate limit
```

## Related CSV Data

- `C:\Users\tomekdot\maniaplanet_feedback_106_with_uid.csv` - 249 maps with 25 columns (8 original + 17 MX)
- `C:\Users\tomekdot\pursuit_channels_new_full_data.json` - Google Sheets raw data
- `C:\Users\tomekdot\pursuit_maps_table.md` - Generated markdown table

## Stats

- Total maps: 249
- Thumbnails downloaded: 248
- Environments: Valley, Canyon, Stadium, Lagoon
- Map types: PursuitArena, GoalHuntArena, HuntersArena
