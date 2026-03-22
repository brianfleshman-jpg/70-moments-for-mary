#!/bin/bash
# Sync submissions from Formspree to the site
# Usage: ./sync.sh

set -e
cd "$(dirname "$0")"

API_KEY="cb4c3c60a51549d3abfdf5d505e40a19"
FORM_ID="xaqpgwkr"

echo "Fetching submissions from Formspree..."

# Fetch submissions via curl, pipe to python for processing
curl -s "https://formspree.io/api/0/forms/${FORM_ID}/submissions" \
  -H "Authorization: Bearer ${API_KEY}" \
  > /tmp/formspree_submissions.json

python3 << 'PYEOF'
import json
import subprocess
import os
import re

PHOTOS_DIR = "assets/photos"
MOMENTS_FILE = "moments.json"
API_KEY = "cb4c3c60a51549d3abfdf5d505e40a19"

# Load submissions from curl output
with open("/tmp/formspree_submissions.json") as f:
    data = json.load(f)

submissions = data.get("submissions", [])
print(f"Found {len(submissions)} submissions")

# Load existing moments
if os.path.exists(MOMENTS_FILE):
    with open(MOMENTS_FILE) as f:
        moments = json.load(f)
else:
    moments = []

# Track existing entries by name+text to avoid duplicates
existing = set()
for m in moments:
    existing.add(f"{m['name']}|{m['text']}")

# Find next moment number
next_num = max([m["number"] for m in moments], default=0) + 1

added = 0
for sub in submissions:
    name = sub.get("name", "").strip()
    text = sub.get("moment", "").strip()
    relationship = sub.get("relationship", "").strip()
    photos = sub.get("photo", [])

    if not name or not text:
        continue

    key = f"{name}|{text}"
    if key in existing:
        continue

    # Download photo if present
    photo_path = None
    if photos and len(photos) > 0:
        photo_url = photos[0]
        safe_name = re.sub(r'[^a-z0-9]', '-', name.lower()).strip('-')
        ext = os.path.splitext(photo_url.split("?")[0])[1] or ".jpg"
        filename = f"{safe_name}-{next_num}{ext}"
        local_path = os.path.join(PHOTOS_DIR, filename)

        try:
            result = subprocess.run(
                ["curl", "-s", "-o", local_path, "-H", f"Authorization: Bearer {API_KEY}", photo_url],
                capture_output=True
            )
            if os.path.exists(local_path) and os.path.getsize(local_path) > 0:
                photo_path = local_path
                print(f"  Downloaded photo: {filename}")
            else:
                print(f"  Warning: photo download empty for {name}")
        except Exception as e:
            print(f"  Warning: couldn't download photo for {name}: {e}")

    moment = {
        "number": next_num,
        "name": name,
        "relationship": relationship,
        "text": text,
        "photo": photo_path,
        "video": None
    }
    moments.append(moment)
    existing.add(key)
    next_num += 1
    added += 1
    print(f"  Added: {name} — {relationship}")

# Remove sample entries
moments = [m for m in moments if m["name"] != "Sample"]

# Save
with open(MOMENTS_FILE, "w") as f:
    json.dump(moments, f, indent=2)

print(f"\nDone. {added} new moments added. Total: {len(moments)}")
PYEOF

echo ""
echo "Pushing to GitHub..."
git add -A
git diff --cached --quiet && echo "No changes to push." || (git commit -m "update: sync new moments from Formspree" && git push)
echo "Done! Site will update in about a minute."
