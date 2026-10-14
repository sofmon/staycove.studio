#!/bin/bash
# Rebuild Slither Orbit (a sibling checkout, or $SLITHER_ORBIT_DIR) into site/games/slither-orbit/.
# Run this whenever the game changes and you want the website copy updated.
# It builds with base=/games/slither-orbit/ into a temp dir (so the game repo's own dist/,
# which Capacitor syncs into the native apps, is left untouched), then patches
# the two root-absolute paths the game assumes (/sw.js and the PWA manifest)
# to live under the same path, and swaps the result into site/games/slither-orbit/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GAME="${SLITHER_ORBIT_DIR:-$ROOT/../slither-orbit}"
SITE="$ROOT/site"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$GAME"
npm run build -- --base=/games/slither-orbit/ --outDir="$TMP/slither-orbit" --emptyOutDir

# The bundle registers the service worker at /sw.js; it must match the deploy path.
sed -i '' 's|"/sw.js"|"/games/slither-orbit/sw.js"|' "$TMP"/slither-orbit/assets/index-*.js

# The built index.html has no SEO meta or favicon of its own; add the site's.
python3 - "$TMP/slither-orbit/index.html" <<'EOF'
import sys
p = sys.argv[1]
html = open(p).read()
extra = '''    <meta name="description" content="Play Slither Orbit free in your browser — a high-speed survival snake game in a circular, gravity-defying arena. No ads, no tracking, no sign-up. By Stay Cove Studio." />
    <link rel="canonical" href="https://staycove.studio/games/slither-orbit/" />
    <link rel="icon" type="image/png" sizes="192x192" href="/games/slither-orbit/icon-192.png" />
    <meta property="og:type" content="website" />
    <meta property="og:title" content="Slither Orbit — play in your browser" />
    <meta property="og:description" content="A high-speed survival snake game in a circular, gravity-defying arena. Dodge the bots and outlast them all." />
    <meta property="og:url" content="https://staycove.studio/games/slither-orbit/" />
    <meta property="og:image" content="https://staycove.studio/assets/og-play.jpg" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta name="twitter:card" content="summary_large_image" />
'''
marker = '<title>Slither Orbit</title>'
assert marker in html, 'title marker not found in built index.html'
html = html.replace(marker, marker + '\n' + extra.rstrip('\n'), 1)
open(p, 'w').write(html)
EOF

# The PWA manifest assumes the site root; scope it to the deploy path.
python3 - "$TMP/slither-orbit/manifest.webmanifest" <<'EOF'
import json, sys
BASE = '/games/slither-orbit'
p = sys.argv[1]
m = json.load(open(p))
m['start_url'] = BASE + '/'
for i in m['icons']:
    if not i['src'].startswith(BASE):
        i['src'] = BASE + i['src']
json.dump(m, open(p, 'w'), indent=2)
EOF

# Carry over the hand-written privacy page, which lives inside the game's directory
# and is not produced by the build. This is its only copy and the swap below deletes
# the directory, so refuse to continue without it rather than silently dropping a
# page the store listings link to.
if [ ! -d "$SITE/games/slither-orbit/privacy" ]; then
  echo "error: $SITE/games/slither-orbit/privacy is missing; refusing to overwrite the site copy" >&2
  exit 1
fi
cp -R "$SITE/games/slither-orbit/privacy" "$TMP/slither-orbit/privacy"

mkdir -p "$SITE/games"
rm -rf "$SITE/games/slither-orbit"
mv "$TMP/slither-orbit" "$SITE/games/slither-orbit"
echo "Updated $SITE/games/slither-orbit"
