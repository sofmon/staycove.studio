#!/usr/bin/env python3
"""Set one sitemap entry's <lastmod> to today, or to a given date.

Called by the build scripts after they rebuild a game, so sitemap.xml keeps
telling the truth about when each page last changed. It edits a single <url>
block in place rather than re-serialising the file, which keeps the hand-written
formatting intact and makes the diff readable.

    ./stamp-sitemap.py site/sitemap.xml https://staycove.studio/games/x/ [YYYY-MM-DD]

Fails loudly if the entry is missing or matches more than once: a sitemap that
silently stops being stamped is worse than a build that stops.
"""
import datetime
import pathlib
import re
import sys


def main(argv):
    if not 3 <= len(argv) <= 4:
        sys.exit(f"usage: {sys.argv[0]} <sitemap.xml> <loc> [YYYY-MM-DD]")

    path, loc = pathlib.Path(argv[1]), argv[2]
    date = argv[3] if len(argv) == 4 else datetime.date.today().isoformat()

    try:
        datetime.date.fromisoformat(date)
    except ValueError:
        sys.exit(f"error: {date!r} is not a YYYY-MM-DD date")

    xml = path.read_text()

    # Anchored on the exact <loc>, so the game's own page is never confused with
    # its /privacy/ child, whose loc starts with the same string.
    pattern = re.compile(
        r"(<loc>" + re.escape(loc) + r"</loc>\s*<lastmod>)(\d{4}-\d{2}-\d{2})(</lastmod>)"
    )
    found = pattern.findall(xml)
    if len(found) != 1:
        sys.exit(
            f"error: expected exactly one <lastmod> for {loc} in {path}, found {len(found)}"
        )

    previous = found[0][1]
    if previous == date:
        print(f"sitemap: {loc} already {date}")
        return

    path.write_text(pattern.sub(rf"\g<1>{date}\g<3>", xml, count=1))
    print(f"sitemap: {loc} {previous} -> {date}")


if __name__ == "__main__":
    main(sys.argv)
