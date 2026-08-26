#!/bin/bash
# Rebuild Slither Orbit (a sibling checkout, or $SLITHER_ORBIT_DIR) into site/play/.
# Run this whenever the game changes and you want the website copy updated.
# It builds with base=/play/ into a temp dir (so the game repo's own dist/,
# which Capacitor syncs into the native apps, is left untouched), then patches
# the two root-absolute paths the game assumes (/sw.js and the PWA manifest)
# to live under /play/, and swaps the result into site/play/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GAME="${SLITHER_ORBIT_DIR:-$ROOT/../slither-orbit}"
SITE="$ROOT/site"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$GAME"
npm run build -- --base=/play/ --outDir="$TMP/play" --emptyOutDir

# The bundle registers the service worker at /sw.js; under /play/ it must be /play/sw.js.
sed -i '' 's|"/sw.js"|"/play/sw.js"|' "$TMP"/play/assets/index-*.js

# The built index.html has no SEO meta or favicon of its own; add the site's.
python3 - "$TMP/play/index.html" <<'EOF'
import sys
p = sys.argv[1]
html = open(p).read()
extra = '''    <meta name="description" content="Play Slither Orbit free in your browser — a high-speed survival snake game in a circular, gravity-defying arena. No ads, no tracking, no sign-up. By Stay Cove Studio." />
    <link rel="canonical" href="https://staycove.studio/play/" />
    <link rel="icon" type="image/png" sizes="192x192" href="/play/icon-192.png" />
    <meta property="og:type" content="website" />
    <meta property="og:title" content="Slither Orbit — play in your browser" />
    <meta property="og:description" content="A high-speed survival snake game in a circular, gravity-defying arena. Dodge the bots and outlast them all." />
    <meta property="og:url" content="https://staycove.studio/play/" />
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

# The PWA manifest assumes the site root; scope it to /play/.
python3 - "$TMP/play/manifest.webmanifest" <<'EOF'
import json, sys
p = sys.argv[1]
m = json.load(open(p))
m['start_url'] = '/play/'
for i in m['icons']:
    if not i['src'].startswith('/play'):
        i['src'] = '/play' + i['src']
json.dump(m, open(p, 'w'), indent=2)
EOF

rm -rf "$SITE/play"
mv "$TMP/play" "$SITE/play"
echo "Updated $SITE/play"
