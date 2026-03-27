# 70 Moments for Mary — Project Handoff

> Mary's 70th birthday keepsake. Party is Saturday March 29, 2026.
> Brian built this with Claude on his personal Mac. This doc is for continuing the work on his work Mac.

---

## What This Is

A website that collects messages and photos from friends and family for Mary's 70th birthday. It has two parts:

1. **Submission form** — people fill out their name, relationship, a message, and optionally a photo. Hosted on GitHub Pages.
2. **Display site** — shows all submitted moments as cards. Has a **TV mode** (slideshow) for displaying at the party on a big screen.

---

## Architecture

**Hosting:** GitHub Pages at `https://brianfleshman-jpg.github.io/70-moments-for-mary/`
**Repo:** `https://github.com/brianfleshman-jpg/70-moments-for-mary.git`
**Form backend:** Formspree (form ID: `xaqpgwkr`)

### Key Files

| File | Purpose |
|------|---------|
| `index.html` | Display page — reads `moments.json`, renders cards. Add `?mode=tv` for fullscreen slideshow |
| `submit.html` | Submission form — posts to Formspree. Shows thank-you on `?thanks=1` |
| `moments.json` | Array of moment objects — the data source for the display page |
| `sync.sh` | Script that pulls new submissions from Formspree API, downloads photos, updates `moments.json`, and pushes to GitHub |
| `assets/photos/` | Downloaded photo files |
| `assets/videos/` | Video files (manual placement) |

### moments.json Format

Each entry:
```json
{
  "number": 4,
  "name": "Brian",
  "relationship": "Son",
  "text": "Hi Mom",
  "photo": "assets/photos/brian-4.jpeg",
  "video": null
}
```

- `number` — display order and label ("Moment 4 of 70")
- `photo` — relative path to local image file, or null
- `video` — relative path to local video file, or null

---

## How to Check for New Submissions

Run the sync script from the project root:

```bash
cd ~/Projects/70-moments
./sync.sh
```

This will:
1. Call the Formspree API to fetch all submissions
2. Compare against existing entries in `moments.json` (deduplicates by name+text)
3. Download any new photos to `assets/photos/`
4. Update `moments.json` with new entries
5. Commit and push to GitHub

The Formspree API key is embedded in `sync.sh`: `cb4c3c60a51549d3abfdf5d505e40a19`

### Manual Sync (if sync.sh has issues)

You can also manually check submissions:

```bash
curl -s "https://formspree.io/api/0/forms/xaqpgwkr/submissions" \
  -H "Authorization: Bearer cb4c3c60a51549d3abfdf5d505e40a19" | python3 -m json.tool
```

---

## How to Add a Moment Manually

If someone texts Brian a photo/message instead of using the form:

1. Add their photo to `assets/photos/` (name it `firstname-N.jpeg`)
2. Add an entry to `moments.json` with the next available number
3. Commit and push

---

## TV Mode (Party Slideshow)

Open: `https://brianfleshman-jpg.github.io/70-moments-for-mary/?mode=tv`

- Click or press any key to start
- **Space** — pause/resume
- **Arrow right** — next slide
- **Arrow left** — previous slide
- **F** — toggle fullscreen
- Each slide shows for 12 seconds (video slides play to completion)
- The final slide is a "grandkids — live" finale card that doesn't auto-advance

---

## Current Status (as of March 27, 2026 evening)

- **14 moments** in `moments.json`:
  - Moment 1: Hero welcome card (Mary & Larry boat photo, intro text from "Your Family")
  - Moments 2-4: Family photos (Brian, Heather, Penelope & Juliette) — photo only, no text
  - Moment 5: Joseph (text submission, no photo)
  - Moment 6: Maria Fernandez (text + photo submission from Formspree)
  - Moment 7: Family photo
  - Moment 8: Judy & Joe (text submission, no photo)
  - Moments 9-14: More family photos
- **3 real submissions** from Formspree (Joseph, Maria Fernandez, Judy & Joe)
- **10 family photos** added manually by Brian, sprinkled between submissions
- Brian's dad sent out a PDF with the submission link via text tonight
- Party is Saturday March 29 — expect more submissions tonight and Friday
- Run `./sync.sh` periodically to pull in new submissions

### Important: Re-sprinkle After More Submissions

When new submissions come in via `sync.sh`, they'll be appended to the end of `moments.json`. Brian may want to re-order and re-number entries to keep the family photos sprinkled evenly between submissions rather than clumped together. Just edit `moments.json` directly — the `number` field controls display order and the "Moment X of 70" label.

---

## Videos / Voice Messages

The form only handles photos. For videos:
- There's an iCloud shared folder link on the submit page
- People can also text videos to Brian at (916) 396-2043
- Videos need to be manually added to `assets/videos/` and referenced in `moments.json`

---

## What Needs to Happen Before Saturday

1. **Run sync.sh regularly** to pull in new submissions as they come in
2. **Manually add** any submissions that come via text/iCloud
3. **Test TV mode** on the actual display (TV/projector) at the party venue
4. **Final sync + push** right before the party starts
