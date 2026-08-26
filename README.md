# staycove.studio

The website for **Stay Cove Studio** — deployed at https://staycove.studio.

## Layout

| Path | What it is |
|---|---|
| `site/` | **The deployable web root.** Point your static host at this folder. |
| `site/index.html` | The one-page studio site (self-contained, no build step, no JS). |
| `site/play/` | Slither Orbit, playable in the browser (built from `../slither-orbit`). |
| `site/slither-orbit/privacy/` | The game's privacy policy (the URL the App Store / Play Store listings require). |
| `site/assets/` | Optimized images and self-hosted fonts (no Google Fonts requests — the site makes zero third-party calls, matching the "no tracking" brand). |
| `staycove-*.png`, `staycovestudio.png` | Source brand art (kept out of the deployed site; web-optimized copies live in `site/assets/`). |
| `build-play.sh` | Rebuilds the game into `site/play/` after game changes. |

## Deploying

The site deploys to **GitHub Pages** automatically: every push to `main` runs
[.github/workflows/pages.yml](.github/workflows/pages.yml), which publishes the
`site/` folder. The custom domain `staycove.studio` is set in the repo's
**Settings → Pages**; DNS at the registrar points the apex at GitHub Pages'
A/AAAA addresses.

The site expects to be served from the **domain root** (paths are `/assets/...`, `/play/...`).

## Updating the game copy

```bash
./build-play.sh
```

This builds the game from a sibling `slither-orbit` checkout (override with the
`SLITHER_ORBIT_DIR` environment variable) with `--base=/play/` and patches its
service-worker path and PWA manifest for the `/play/` subpath. It does not touch
the game repo's own `dist/` (which Capacitor syncs into the iOS/Android projects).

## Local preview

```bash
python3 -m http.server 4173 --directory site
```
