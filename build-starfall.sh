#!/bin/bash
# Rebuild Starfall Vanguard (a sibling checkout, or $STARFALL_DIR) into site/starfall-vanguard/.
# Run this whenever the game changes and you want the website copy updated.
# The game builds with a RELATIVE base (vite.config.ts: base: './'), so unlike
# Slither Orbit it needs no path patching — it works at any subpath as-is.
# The only things added here are the site's SEO metadata and favicon, which the
# game's own index.html does not carry, and the hand-written privacy page.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
GAME="${STARFALL_DIR:-$ROOT/../game-2}"
SITE="$ROOT/site"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$GAME"
# --outDir keeps the game repo's own dist/ intact (Capacitor syncs that into the
# native iOS/Android projects); the flags land on the `vite build` at the end of
# the package's build script.
npm run build -- --outDir "$TMP/starfall-vanguard" --emptyOutDir

python3 - "$TMP/starfall-vanguard/index.html" <<'PY'
import sys
p = sys.argv[1]
html = open(p).read()
extra = '''    <link rel="canonical" href="https://staycove.studio/starfall-vanguard/" />
    <link rel="icon" type="image/png" sizes="48x48" href="/assets/favicon-48.png" />
    <link rel="apple-touch-icon" href="/assets/apple-touch-icon.png" />
    <meta property="og:type" content="website" />
    <meta property="og:title" content="Starfall Vanguard — play in your browser" />
    <meta property="og:description" content="A vertical-scrolling arcade shoot-'em-up with a deep modular ship editor. Three stages, multi-phase bosses, and an endless survival mode." />
    <meta property="og:url" content="https://staycove.studio/starfall-vanguard/" />
    <meta property="og:image" content="https://staycove.studio/assets/og-starfall.jpg" />
    <meta property="og:image:width" content="1200" />
    <meta property="og:image:height" content="630" />
    <meta name="twitter:card" content="summary_large_image" />'''
marker = '<title>Starfall Vanguard</title>'
assert marker in html, 'title marker not found in built index.html'
html = html.replace(marker, marker + '\n' + extra, 1)
html = html.replace(
  '<meta name="description" content="Starfall Vanguard - a vertical-scrolling arcade shoot-em-up." />',
  '<meta name="description" content="Play Starfall Vanguard free in your browser — a vertical-scrolling arcade shoot-\'em-up with a modular ship editor. No ads, no tracking, no sign-up. By Stay Cove Studio." />', 1)
open(p, 'w').write(html)
PY

# Carry over the hand-written privacy page, which lives inside the game's directory
# and is not produced by the build. This is its only copy, so refuse to continue
# without it rather than silently dropping a page the store listings link to.
if [ ! -d "$SITE/starfall-vanguard/privacy" ]; then
  echo "error: $SITE/starfall-vanguard/privacy is missing; refusing to overwrite the site copy" >&2
  exit 1
fi
cp -R "$SITE/starfall-vanguard/privacy" "$TMP/starfall-vanguard/privacy"

rm -rf "$SITE/starfall-vanguard"
mv "$TMP/starfall-vanguard" "$SITE/starfall-vanguard"
echo "Updated $SITE/starfall-vanguard"
