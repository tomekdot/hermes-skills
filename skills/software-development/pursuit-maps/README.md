# Pursuit Maps Pipeline

Automated pipeline that collects map data from ManiaPlanet Feedback + ManiaExchange
and syncs it to Google Sheets via GAS Web App.

**Repo**: https://github.com/tomekdot/pursuit-maps

## What It Does

1. **Fetches 249 maps** from ManiaPlanet Feedback with:
   - YES/NO Rating (separate from 5-Star!)
   - 5-Star Average + total vote count
   - Map name, UID, thumbnail hash

2. **Enriches with ManiaExchange API** for Author, Environment, MapType

3. **Pushes to Google Sheets** via GAS Web App (zero credentials needed)

4. **Tracks vote changes** daily at 5:00 UTC

## Repo Structure

```
pursuit-maps/
├── pipeline/
│   ├── pipeline.py              ← Main script (sync + votes + report + validate)
│   ├── gas_runner.py            ← HTTP client for GAS Web App
│   ├── all_maps.tsv             ← All 249 maps with vote data
│   ├── gas_sync_payload.json    ← GAS sync payload
│   └── gas-webapp/
│       ├── PursuitMaps.gs       ← Deploy once in Sheet
│       └── README.md            ← GAS setup guide
├── data/
│   ├── feedback_full.json       ← Cached feedback data
│   ├── vote_history.json        ← Vote snapshots (90 days)
│   └── vote_report.md           ← Generated vote change report
├── docs/
│   ├── GOOGLE_SHEETS_SETUP.md
│   └── SHEETS_WRITE_SETUP.md
├── scripts/legacy/              ← Old scripts (reference only)
├── assets/thumbnails/           ← 248 map thumbnail JPGs
└── .github/workflows/
    └── pipeline.yml             ← Daily 5:00 UTC auto-sync
```

## Usage

```bash
# Full pipeline (sync + votes + report)
python3 pipeline/pipeline.py

# Individual actions
python3 pipeline/pipeline.py --action sync       # Fetch + push new maps
python3 pipeline/pipeline.py --action votes      # Update vote columns
python3 pipeline/pipeline.py --action report     # Vote change report
python3 pipeline/pipeline.py --action validate   # Data quality checks
```

Requires `GAS_WEBAPP_URL` env var or `pipeline/gas_url.txt`.

## Sheet Columns

| Col | Name | Source |
|-----|------|--------|
| A | # | Auto |
| B | Map name | Feedback |
| C | Author login | ManiaExchange |
| D | Environment | ManiaExchange |
| E | Uploaded at | ManiaExchange |
| F | UID | Feedback |
| G | MapType | ManiaExchange |
| H | Notes | Manual |
| I | YN Rating | Feedback (YES/NO section) |
| J | YN Votes | Feedback (YES/NO section) |
| K | 5-Star Avg | Feedback (5 STARS section) |
| L | 5-Star Total | Feedback (5 STARS section) |

## Key APIs

- **Feedback page**: `feedback.prod.live.maniaplanet.com/votes/display/106`
- **MX API**: `tm.mania.exchange/api/maps/get_map_info/id/{UID}` (V1, accepts UID)
- **Sheet read**: gviz API (no auth for public sheets)
- **Sheet write**: GAS Web App (deployed once per user)

## Writing to Sheet

The **GAS Web App** approach requires zero credentials:

1. Deploy `pipeline/gas-webapp/PursuitMaps.gs` once in Sheet (Extensions → Apps Script → Deploy as Web App)
2. Save the Web App URL as `GAS_WEBAPP_URL` env var or `pipeline/gas_url.txt`
3. Pipeline sends HTTP POST with JSON → GAS writes to Sheet on your behalf

## Parsing Notes

The Feed page has **two separate** star rating sections per map card:
- `<h6>YES/NO</h6>` → gold span → `rating (count)` 
- `<h6>5 STARS</h6>` → gold span → `rating (count)`

These must be parsed independently. ~80% of maps have 5-Star data but no YES/NO votes.

HTML parsing: split at each `<img src="...maps/...">` to isolate per-map cards, then split each card by YES/NO vs 5 STARS sections.

## Stats

- 249 maps total
- ~75% indexed on ManiaExchange
- 248 thumbnails available
- 4 environments: Valley, Canyon, Stadium, Lagoon
- 3 map types: PursuitArena (~80%), GoalHuntArena (~15%), HuntersArena (~5%)

## License

MIT
