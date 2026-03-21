# 70 Moments for Mary — Design Spec

## Purpose

A digital keepsake for Mary's 70th birthday. 30ish people submit moments (photo + message, text-only, or video) via a Google Form before the party. The moments are displayed as a full-screen slideshow on a TV at the party (March 28) via AirPlay, and live forever as a scrollable keepsake page Mary can visit on her phone.

## System Overview

Two independent pieces:

1. **Google Form** — collects submissions. Files land in Brian's Google Drive.
2. **Static HTML site on GitHub Pages** — one page, two modes (TV slideshow + phone keepsake). No backend, no database, no accounts.

Brian manually curates: downloads submissions from Drive, organizes into a data file and asset folders, pushes to GitHub.

## Google Form

Five fields:
- **Your name** (short text, required)
- **Your relationship to Mary** (short text, e.g. "daughter", "neighbor")
- **Your moment** (paragraph text — memory, message, or caption)
- **Photo** (file upload, optional)
- **Video or voice message** (file upload, optional)

Brian creates this in Google Forms manually. No code needed — just instructions.

## Display Site

### Data Structure

A single `moments.json` at the project root:

```json
[
  {
    "number": 1,
    "name": "Brian",
    "relationship": "Son",
    "text": "Christmas '94 — you let me eat cookie dough even though Dad said no.",
    "photo": "assets/photos/brian.jpg",
    "video": null
  },
  {
    "number": 2,
    "name": "Heather",
    "relationship": "Daughter-in-law",
    "text": "You taught me that kindness isn't weakness — it's the hardest kind of strength.",
    "photo": null,
    "video": null
  },
  {
    "number": 47,
    "name": "Mike & Julie",
    "relationship": "Friends",
    "text": "A message from across the country — we wish we were there!",
    "photo": null,
    "video": "assets/videos/mike-julie.mp4"
  }
]
```

Assets live in:
- `assets/photos/` — photos and drawings
- `assets/videos/` — video and voice messages

### Phone Mode (default)

The permanent keepsake Mary visits on her phone/iPad.

- Hero: large gradient "70" + "Moments for Mary" + subtitle
- Scrollable cards, one per moment
- Photo moments: image displayed with caption text and contributor name/relationship below
- Text-only moments: large quote-style typography with name/relationship
- Video moments: embedded video player with caption
- Apple-style aesthetic: `-apple-system` font, clean whites/grays, warm accents
- Matches the visual language of the v2 design doc at `~/.superpowers/brainstorm/80165-1774033047/design-70-moments-v2.html`

### TV Mode (`?mode=tv`)

Activated by URL parameter. Designed for AirPlay to Apple TV — full-screen browser.

- Dark background (#000 or near-black)
- Auto-advances every 12 seconds (photos/text), videos play to completion
- Photo moments: photo fills screen, caption and name overlaid at bottom
- Text-only moments: large elegant white text centered on dark background
- Video moments: plays with sound, auto-advances when done
- Progress: "Moment 14 of 70" indicator, subtle
- Moment #70: displays a "The grandkids — live" holding card and pauses (does not auto-advance), signaling the live finale
- Keyboard controls: spacebar to pause/resume, arrow keys for manual advance

### Styling

- Font: `-apple-system, 'SF Pro Display', 'SF Pro Text', 'Helvetica Neue', sans-serif`
- Phone mode: white background, `#1d1d1f` text, `#86868b` secondary, `#f5f5f7` card backgrounds
- TV mode: `#000` background, white text, subtle opacity for secondary elements
- Gradient accent: `linear-gradient(135deg, #af52de, #ff2d55, #ff9500)` for the "70"
- Cards: `border-radius: 20px`, subtle hover scale
- Responsive: works on phone, tablet, desktop, and TV

## File Structure

```
~/Projects/70-moments/
  index.html          — the single-page app (phone + TV modes)
  moments.json        — curated moment data
  assets/
    photos/           — uploaded photos
    videos/           — uploaded videos
  docs/               — spec and plan docs
```

## Curation Workflow

1. Brian creates Google Form, sends link to ~30 people
2. Submissions arrive in Google Drive
3. Brian downloads photos/videos, renames them sensibly (e.g. `brian.jpg`)
4. Brian edits `moments.json` — adds entries, sets order, assigns numbers
5. `git add . && git push` — GitHub Pages deploys automatically
6. Repeat as more submissions arrive through the week
7. Day before party: final ordering, moment #70 set as grandkids finale

## Hosting

- GitHub Pages from main branch
- Repository: `70-moments-for-mary` (or similar)
- URL: `https://<username>.github.io/70-moments-for-mary/`
- Free, permanent, no maintenance

## Constraints

- Party: March 28, 2026 — 7 days from now
- ~30 contributors max
- No backend, no build tools, no frameworks — vanilla HTML/CSS/JS
- Must work on all devices via standard browser
- TV mode via AirPlay from any Apple device
- Mary keeps the URL forever

## Out of Scope

- User accounts or authentication
- Real-time live submissions at the party
- Automatic ingestion from Google Form (manual curation)
- Custom domain (GitHub Pages default URL is fine)
