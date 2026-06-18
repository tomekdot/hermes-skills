---
name: maniaplanet-items-organizer
description: Organize ManiaPlanet/TM2020 Item Sets by size and category. Scan the Items/Sets folder, classify item packs into thematic categories (Stadium, Terrain, Decoration, Gameplay, etc.), sort into Large/Medium/Small size tiers, and move everything out of root. Use when the Items/Sets folder has accumulated many unsorted item packs.
version: 1.0.0
metadata:
  hermes:
    tags: [maniaplanet, trackmania, item-sets, file-organizer, gaming, windows]
  author: tomekdot
  license: MIT
---

# 🎮 ManiaPlanet Items Organizer

## 📋 Overview

ManiaPlanet/TM2020 item sets accumulate over time — downloaded items from community creators pile up in `Documents/ManiaPlanet/Items/Sets/` as flat folders with no structure. This skill provides a repeatable strategy for sorting them by **size tier** and **thematic category**.

> 💡 Tested on: `C:\Users\tomekdot\Documents\ManiaPlanet\Items\Sets` — 180 entries, 1.4GB → organized into clean 3-tier structure.

---

## 📁 Target Folder

```
C:\Users\<user>\Documents\ManiaPlanet\Items\Sets\
```

This is the default location where ManiaPlanet/TM2020 stores downloaded community item packs.

**Do NOT touch:**
- `C:\Users\<user>\Documents\ManiaPlanet\Items\` (parent — contains other item types)
- Any `.gbx` files that are items currently in use in maps

---

## 📊 Step 1: Scan & Measure Sizes

**⚠️ `python3` is WRONG on this Windows host. Use `python` (from venv).**

Run from the `Sets/` folder:

```bash
cd "/c/Users/<user>/Documents/ManiaPlanet/Items/Sets"
python -c "
import os, pathlib
base = pathlib.Path('.')
sizes = []
for entry in base.iterdir():
    try:
        if entry.is_file():
            size = entry.stat().st_size
        elif entry.is_dir():
            total = 0
            for root, dirs, files in os.walk(entry):
                for f in files:
                    fp = os.path.join(root, f)
                    try: total += os.path.getsize(fp)
                    except: pass
            size = total
        else:
            size = 0
        sizes.append((size, entry.name, entry.is_dir()))
    except: sizes.append((0, entry.name, False))
sizes.sort(reverse=True)
def h(n):
    for u in ['B','KB','MB','GB']:
        if n < 1024: return f'{n:.1f}{u}'
        n /= 1024
    return f'{n:.1f}TB'
for s,n,d in sizes:
    print(f'{h(s):>8}  {\"DIR\" if d else \"FILE\"}  {n}')
print(f'\nTotal: {len(sizes)} entries, {h(sum(s for s,_,_ in sizes))}')
"
```

This produces a sorted list: SIZE, TYPE (DIR/FILE), NAME.

---

## 🏷️ Step 2: Classify by Category

Each folder name suggests its category. Use these patterns:

| 🏷️ Category | 🔍 Matching Patterns | Examples |
|---|---|---|
| 🏟️ **Stadium** | `Stadium*`, `F1_Stadium`, `*Stadium*`, `tm2*Smurf*`, `MiscStadium*` | StadiumExtensions, F1_Stadium, tm2-SmurfStadium |
| 🏔️ **Terrain_Platform** | `Block*`, `Platform*`, `Ramp*`, `Slope*`, `Trench*`, `Underground*`, `Dirt*`, `Grass`, `Concrete`, `Metal*`, `Glass`, `Road`*, `Strip*`, `Flat*`, `Loop*`, `Magnet`, `Island`, `Sky*`, `Splash*`, `Sculpt*` | Blocks, Ramp, Grass, Loop, SculptCurves |
| 🏗️ **Structures** | `Bridge`, `Castle*`, `Elevator`, `Pillar*`, `Pipe*`, `Prefab`, `Rexasaurus`, `Ring*`, `Angled*`, `Canyon*` | Bridge, Castles, Elevator, Canyon port |
| 🎨 **Decoration** | `Decoration`, `Light*`, `Prop*`, `Party`, `Lego`, `Space`, `Valley*`, `Asset*`, `Import*`, `Lilypad*`, `Tree*`, `S_Tree*`, `S_Part*`, `*Deco*` | Decoration, Lights, Props, Lego |
| 🚗 **Vehicles_Props** | `CarPark`, `MX`, `Helicopter*`, `S_Heli*`, `C-17`, `Trailer*`, `Kart*`, `Bobsleigh`, `Stunt*` | CarPark, Helicopter, KartKit |
| ⚡ **Gameplay** | `Waypoint*`, `Control*`, `Start*`, `Turbo*`, `Nitro*`, `Magnet`, `Ruler*`, `ItemSign*`, `*Fix*`, `Spawn*`, `FreeCP*`, `S_*` | ControlInOut, WaypointsFix, ItemSigns |
| 🎪 **Arena_Special** | `Storm`, `Skyslide*`, `Shootmania*`, `*Bumper*`, `Halfpipe*`, `BigArena*` | Storm, SkyslideCreations, BigArenaHoleBumpers |
| 📦 **Packs** | `Pack`, `Set *`, `Item`, `RPG*`, `TM2_RPG*`, `Xmas*`, `Pack`, `*Basket*`, `MX`, `MyItems`, `Unofficial*`, `*Parts*` | Pack, Xmas_Pack_2013, RPG, TM2_RPG_Items |
| 📦 **Collections** (large packs) | `ManiaPark`, `New folder`, `NewFolder`, `STR`, `S_*_Pack*` | ManiaPark, STR |

**Edge cases:**
- `ManiaPark` → always Terrain_Platform (Nadeo's own set, huge)
- `Temp` → Junk
- `New folder`, `NewFolder` → Decoration (usually recent downloads)
- `funny shit item`, `Kory`, `iyublock1`, `tomekdot` → Junk
- `zzz*` → Junk or Arena_Special (check size)
- `*Imported*` → Junk/Decoration
- Folders with `S_` prefix → usually small gameplay/utility items
- Folders starting with numbers or dates → Packs

---

## 📏 Step 3: Assign Size Tiers

| Tier | Size | Target Folder |
|---|---|---|
| 🔴 Large | > 10 MB | `01-Large/<category>/` |
| 🟡 Medium | 1–10 MB | `02-Medium/<category>/` |
| 🟢 Small | < 1 MB | `03-Small/<category>/` |
| ⚪ Root files | any `.Gbx` in root | `00-RootFiles/` |
| 🗑️ Junk | any | `03-Small/Junk/` |

---

## 🏗️ Step 4: Create Folder Structure

```bash
cd "/c/Users/<user>/Documents/ManiaPlanet/Items/Sets"

mkdir -p \
  "01-Large/Stadium" "01-Large/Terrain_Platform" "01-Large/Collections" \
  "01-Large/Arena_Special" "01-Large/Structures" "01-Large/Decoration" \
  "02-Medium/Stadium" "02-Medium/Terrain_Platform" "02-Medium/Road" \
  "02-Medium/Structures" "02-Medium/Decoration" "02-Medium/Gameplay" \
  "02-Medium/Vehicles_Props" "02-Medium/Arena_Special" "02-Medium/Packs" \
  "03-Small/Stadium" "03-Small/Terrain_Platform" "03-Small/Road" \
  "03-Small/Structures" "03-Small/Decoration" "03-Small/Gameplay" \
  "03-Small/Vehicles_Props" "03-Small/Arena_Special" "03-Small/Packs" \
  "03-Small/Junk" \
  "00-RootFiles"
```

---

## 🔄 Step 5: Move Folders (Batched)

Move in batches by category, one `mv` per line. Use proper quoting for names with spaces:

```bash
# Example — Stadium
mv StadiumExtensions "01-Large/Stadium/"
mv Stadium2Ice "01-Large/Stadium/"
mv "F1_Stadium" "01-Large/Stadium/"
```

**⚠️ `Permission denied` handling:**
- If a folder gives `Permission denied`, it's likely open in ManiaPlanet editor
- Skip it, notify the user, continue with the rest
- Retry after user closes the editor:
  ```bash
  mv Parts "01-Large/Terrain_Platform/"  # retry
  ```

**⚠️ `New folder` / `NewFolder`:**
- Windows may have both. `New folder` is the default Windows duplicate name
- Both are usually just unsorted recent downloads → Decoration or Junk

---

## 📁 Step 6: Move Root `.Gbx` Files

Pliki `.Gbx` zleżałe w root `Sets/` nie powinny tam być:

```bash
mv AutoSave.Crystal.Gbx "00-RootFiles/"
mv Item.Item.Gbx "00-RootFiles/"
mv Sculpt1_Straight.Item.Gbx "00-RootFiles/"
# ... etc
```

`00-RootFiles/` acts as a quarantine — user can review and delete or re-import later.

---

## ✅ Step 7: Verify

```bash
# Check root is clean (only 00-, 01-, 02-, 03- folders remain)
ls -la "/c/Users/<user>/Documents/ManiaPlanet/Items/Sets"

# Count entries per tier
for d in 0*/; do echo "📁 $d → $(ls -1 "$d" | wc -l) entries"; done

# Count entries per category
for d in 01-Large/*/ 02-Medium/*/ 03-Small/*/; do
  echo "  📂 $d → $(ls -1 "$d" | wc -l) folders"
done
```

Expected: only `00-RootFiles`, `01-Large`, `02-Medium`, `03-Small` in root.

---

## ⚠️ Pitfalls

| Problem | Solution |
|---|---|
| `python3` not found | Use `python` (venv-based, on this Windows host) |
| `Permission denied` on `mv` | Folder open in ManiaPlanet — skip, notify user, retry later |
| `mv: cannot move — file exists` | Target already has same-named folder; it was pre-existing, use `cp -r` + `rm -rf` or skip |
| `du -sh *` takes too slow | Use the Python scanner above — faster, single pass |
| Folders with special chars (`, `'`, `&`) | Always quote in `mv "name" "dest/"` |
| `New folder` conflicts | Windows may auto-create `New folder (2)` etc. Handle each as separate |

---

## 🧹 Maintenance

Run organization:
- **When**: Every few months or when Sets/ root exceeds ~50 entries
- **New downloads**: Community items land directly in root — re-run steps 1–7
- **ManiaPlanet safe**: Moving folders in `Items/Sets/` does NOT break existing maps (maps reference items by ID, not path)
