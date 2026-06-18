---
name: pursuit-maps
description: "TrackMania Pursuit maps pipeline: fetches 249 maps from ManiaPlanet Feedback (star ratings, vote counts), enriches with ManiaExchange data, syncs to Google Sheets via GAS Web App. Daily automated pipeline with vote tracking."
version: 2.0.0
author: OWL
tags: ["trackmania", "pursuit", "maniaplanet", "maps", "thumbnails", "gas", "google-sheets", "pipeline"]
---

# Pursuit Maps Pipeline

Automated pipeline: ManiaPlanet Feedback + ManiaExchange → Google Sheets.

## Quick Reference

**Main script**: `pipeline/pipeline.py` in repo `tomekdot/pursuit-maps`

```bash
python3 pipeline/pipeline.py                    # full pipeline
python3 pipeline/pipeline.py --action sync      # fetch + push new maps + auto-sort
python3 pipeline/pipeline.py --action votes     # update vote columns only
python3 pipeline/pipeline.py --action sort      # sort sheet by Uploaded At
python3 pipeline/pipeline.py --action report    # vote change report
python3 pipeline/pipeline.py --action validate  # data quality checks
```

**GAS Web App**: `pipeline/gas-webapp/PursuitMaps.gs` — deploy once in Sheet (Extensions → Apps Script → Deploy as Web App). Accepts HTTP POST from pipeline.

## Repo Structure

```
pursuit-maps/
├── pipeline/pipeline.py      ← Main entry point (all actions)
├── pipeline/gas_runner.py    ← HTTP client for GAS
├── pipeline/gas-webapp/      ← GAS script (deploy in Sheet)
├── data/                     ← Cache, history, reports
├── docs/                     ← Setup guides
├── scripts/legacy/           ← Old scripts (reference)
└── .github/workflows/pipeline.yml  ← Daily 5:00 UTC
```

## Sheet Columns

| Col | Name | Source |
|-----|------|--------|
| A | # | Auto |
| B | Map name | Feedback |
| C | Author login | ManiaExchange |
| D | Environment | ManiaExchange |
| E | Uploaded at | ManiaExchange (ISO 8601 → normalized to YYYY-MM-DD HH:MM:SS) |

## Sorting

Sheet is auto-sorted by **Uploaded At (column E) descending** after every sync (newest maps on top).
- Column E is formatted as Date (`yyyy-mm-dd hh:mm:ss`) so Sheets treats it as proper date
- Manual sort: `python3 pipeline/pipeline.py --action sort` or POST `{"action":"sort"}` to GAS
- Sort function handles both Date objects and string dates from MX API
| F | UID | Feedback |
| G | TrackMania\MapType | ManiaExchange |
| H | Notes | Manual |
| I | YN Rating | Feedback YES/NO section |
| J | YN Votes | Feedback YES/NO section |
| K | 5-Star Avg | Feedback 5 STARS section |
| L | 5-Star Total | Feedback 5 STARS section |

## Key API Endpoints

- Feedback page: `feedback.prod.live.maniaplanet.com/votes/display/106`
- MX API: `tm.mania.exchange/api/maps/get_map_info/id/{UID}` (V1, accepts UID)
- Sheet read: gviz API (no auth for public sheets)
- Sheet write: GAS Web App (deployed once per user)

## Parsing Notes

Feed page has TWO separate star rating sections per map card:
1. **YES/NO** section: `<h6>YES/NO</h6>` → gold span → `rating (count)` 
2. **5 STARS** section: `<h6>5 STARS</h6>` → gold span → `rating (count)`

Parse independently. ~80% of maps have 5-Star data but no YES/NO votes.

Split HTML at each `<img src="...maps/...">` to isolate per-map cards.

## Stats

- 249 maps total
- ~75% indexed on ManiaExchange
- 248 thumbnails available (1 HTTP 403)
- 4 environments: Valley, Canyon, Stadium, Lagoon
- 3 map types: PursuitArena (~80%), GoalHuntArena (~15%), HuntersArena (~5%)
