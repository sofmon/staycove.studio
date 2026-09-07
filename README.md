# staycove.studio

The website for **Stay Cove Studio** — deployed at https://staycove.studio.

## Layout

| Path | What it is |
|---|---|
| `site/` | **The deployable web root.** Point your static host at this folder. |
| `site/index.html` | The one-page studio site (self-contained, no build step, no JS). |
| `site/games/slither-orbit/` | **Slither Orbit**, playable in the browser (built from `../slither-orbit`), with its privacy policy under `privacy/` (the URL the App Store / Play Store listings require). |
| `site/games/starfall-vanguard/` | **Starfall Vanguard**, playable in the browser (built from `../game-2`), with its privacy policy under `privacy/`. |
| `site/play/`, `site/starfall-vanguard/`, `site/slither-orbit/privacy/` | Redirect stubs for the games' previous URLs — see "Moved URLs" below. Do not delete. |
| `site/assets/` | Optimized images and self-hosted fonts (no Google Fonts requests — the site makes zero third-party calls, matching the "no tracking" brand). |
| `staycove-*.png`, `staycovestudio.png` | Source brand art (kept out of the deployed site; web-optimized copies live in `site/assets/`). |
| `build-play.sh` | Rebuilds Slither Orbit into `site/play/` after game changes. |
| `build-starfall.sh` | Rebuilds Starfall Vanguard into `site/starfall-vanguard/` after game changes. |

## Deploying

The site deploys to **GitHub Pages** automatically: every push to `main` runs
[.github/workflows/pages.yml](.github/workflows/pages.yml), which publishes the
`site/` folder. The custom domain `staycove.studio` is set in the repo's
**Settings → Pages**; DNS at the registrar points the apex at GitHub Pages'
A/AAAA addresses.

The site expects to be served from the **domain root** (paths are `/assets/...`, `/games/...`).

## Updating the game copies

```bash
./build-play.sh        # Slither Orbit     -> site/games/slither-orbit/
./build-starfall.sh    # Starfall Vanguard -> site/games/starfall-vanguard/
```

`build-play.sh` builds from a sibling `slither-orbit` checkout (override with
`SLITHER_ORBIT_DIR`) with `--base=/games/slither-orbit/`, and patches its
service-worker path and PWA manifest for that subpath. Slither Orbit bakes absolute
paths into its bundle, so it must be **rebuilt** — not merely moved — if its URL
ever changes again.

`build-starfall.sh` builds from a sibling `game-2` checkout (override with
`STARFALL_DIR`). That game already builds with a relative base, so it needs no path
patching — the script only injects the site's SEO metadata and favicon, and preserves
the hand-written privacy page.

Neither script touches the game repos' own `dist/` folders (which Capacitor syncs
into the iOS/Android projects).

## Moved URLs

Both games live under `/games/<game>/`. Their earlier addresses are kept as redirect
stubs so old links, bookmarks and any already-installed PWA keep working:

| Old URL | Redirects to |
|---|---|
| `/play/` | `/games/slither-orbit/` |
| `/starfall-vanguard/` | `/games/starfall-vanguard/` |
| `/slither-orbit/privacy/` | `/games/slither-orbit/privacy/` |

GitHub Pages cannot issue real 301s, so each stub is an HTML page with a canonical
link, a zero-delay meta refresh, a JS `location.replace`, and a visible fallback link.
The `/play/` stub additionally unregisters the old service worker that was scoped to
that path, so a stale copy cannot keep serving the game from the old address. The
stubs are deliberately **not** listed in `sitemap.xml`.

## Local preview

```bash
python3 -m http.server 4173 --directory site
```
