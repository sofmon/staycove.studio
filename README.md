# staycove.studio

The website for **Stay Cove Studio** — deployed at https://staycove.studio.

## Layout

| Path | What it is |
|---|---|
| `site/` | **The deployable web root.** Point your static host at this folder. |
| `site/index.html` | The one-page studio site (self-contained, no build step, no JS). |
| `site/play/` | **Slither Orbit**, playable in the browser (built from `../slither-orbit`). |
| `site/slither-orbit/privacy/` | Slither Orbit's privacy policy (the URL the App Store / Play Store listings require). |
| `site/starfall-vanguard/` | **Starfall Vanguard**, playable in the browser (built from `../game-2`). |
| `site/starfall-vanguard/privacy/` | Starfall Vanguard's privacy policy. |
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

The site expects to be served from the **domain root** (paths are `/assets/...`, `/play/...`).

## Updating the game copies

```bash
./build-play.sh        # Slither Orbit  -> site/play/
./build-starfall.sh    # Starfall Vanguard -> site/starfall-vanguard/
```

`build-play.sh` builds from a sibling `slither-orbit` checkout (override with
`SLITHER_ORBIT_DIR`) with `--base=/play/`, and patches its service-worker path and
PWA manifest for the `/play/` subpath.

`build-starfall.sh` builds from a sibling `game-2` checkout (override with
`STARFALL_DIR`). That game already builds with a relative base, so it needs no path
patching — the script only injects the site's SEO metadata and favicon, and preserves
the hand-written privacy page.

Neither script touches the game repos' own `dist/` folders (which Capacitor syncs
into the iOS/Android projects).

> **Note on URLs:** Slither Orbit lives at `/play/` for historical reasons and
> Starfall Vanguard at `/starfall-vanguard/`. Both are linked from the home page, so
> the difference is invisible in normal use; unifying them would break the older
> game's already-published URL.

## Local preview

```bash
python3 -m http.server 4173 --directory site
```
