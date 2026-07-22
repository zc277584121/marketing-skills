#!/usr/bin/env python3
"""Check Agent Browser and Chrome versions before browser viewport recording."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path


CHROME_VERSIONHISTORY_URL = (
    "https://versionhistory.googleapis.com/v1/chrome/platforms/mac/channels/stable/versions"
    "?page_size=1&order_by=version%20desc"
)


@dataclass
class CheckResult:
    name: str
    current: str | None
    latest: str | None
    ok: bool
    note: str | None = None


def run_text(cmd: list[str], timeout: int = 20) -> str | None:
    try:
        result = subprocess.run(cmd, check=True, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=timeout)
    except (FileNotFoundError, subprocess.CalledProcessError, subprocess.TimeoutExpired):
        return None
    return result.stdout.strip()


def parse_version(text: str | None) -> str | None:
    if not text:
        return None
    match = re.search(r"\d+(?:\.\d+)+", text)
    return match.group(0) if match else None


def version_tuple(version: str | None) -> tuple[int, ...] | None:
    if not version:
        return None
    return tuple(int(part) for part in version.split(".") if part.isdigit())


def is_at_least(current: str | None, latest: str | None) -> bool:
    current_tuple = version_tuple(current)
    latest_tuple = version_tuple(latest)
    if not current_tuple or not latest_tuple:
        return False
    return current_tuple >= latest_tuple


def latest_chrome_version(timeout: int) -> str | None:
    try:
        with urllib.request.urlopen(CHROME_VERSIONHISTORY_URL, timeout=timeout) as response:
            data = json.load(response)
    except Exception:
        return None
    versions = data.get("versions") or []
    if not versions:
        return None
    return versions[0].get("version")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--chrome-binary",
        default="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        help="Path to the local Google Chrome binary.",
    )
    parser.add_argument("--timeout", type=int, default=20, help="Network and command timeout in seconds.")
    parser.add_argument("--json", action="store_true", help="Print machine-readable JSON.")
    parser.add_argument(
        "--warn-only",
        action="store_true",
        help="Always exit 0, even if a version is outdated or unknown.",
    )
    args = parser.parse_args()

    agent_current = parse_version(run_text(["agent-browser", "--version"], timeout=args.timeout))
    agent_latest = parse_version(run_text(["npm", "view", "agent-browser", "version"], timeout=args.timeout))

    chrome_path = Path(args.chrome_binary)
    chrome_current = None
    if chrome_path.exists():
        chrome_current = parse_version(run_text([str(chrome_path), "--version"], timeout=args.timeout))
    chrome_latest = latest_chrome_version(args.timeout)

    results = [
        CheckResult(
            "agent-browser",
            agent_current,
            agent_latest,
            is_at_least(agent_current, agent_latest),
            None if agent_current and agent_latest else "Could not read local or latest Agent Browser version.",
        ),
        CheckResult(
            "google-chrome-mac-stable",
            chrome_current,
            chrome_latest,
            is_at_least(chrome_current, chrome_latest),
            None if chrome_current and chrome_latest else "Could not read local or latest Chrome stable version.",
        ),
    ]

    payload = {
        "ok": all(result.ok for result in results),
        "source": {
            "agent_browser_latest": "npm view agent-browser version",
            "chrome_latest": CHROME_VERSIONHISTORY_URL,
        },
        "results": [result.__dict__ for result in results],
    }

    if args.json:
        print(json.dumps(payload, indent=2))
    else:
        for result in results:
            status = "OK" if result.ok else "OUTDATED_OR_UNKNOWN"
            print(f"{status} {result.name}: current={result.current or 'unknown'} latest={result.latest or 'unknown'}")
            if result.note:
                print(f"  note: {result.note}")

    if payload["ok"] or args.warn_only:
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
