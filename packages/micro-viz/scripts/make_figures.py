"""Generate the figures of the micro-viz manual with the package's example scripts.

Run from the manual's directory (micro-viz/):

    uv run python scripts/make_figures.py                 # every script, every edition
    uv run python scripts/make_figures.py costs monopoly  # some scripts
    uv run python scripts/make_figures.py --list          # list the scripts

The figures are drawn by the real example scripts in scripts/examples/, once per edition
from that edition's settings file (config/econ-viz.toml, econ-viz.zh-TW.toml or
econ-viz.zh-CN.toml: the black-and-white "manual" look, the edition's fonts, and micro-viz's
built-in words in the edition's language). Figures carry no titles; captions are written in
Typst.

Each script writes into figures/<script>/<figure>[.<edition>].svg (English has no suffix),
and a copy of the script with its common.py is placed beside the figures, so the examples
archive on the website can run them from there.
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = ROOT / "scripts" / "examples"
OUT = ROOT / "figures"
FONTS = ROOT.parent.parent / "fonts"  # agora/fonts: Noto Serif TC and SC
EDITIONS = ("en", "zh-TW", "zh-CN")

# Scripts that draw the manual's static figures, in chapter order.
STATIC = (
    "production", "costs", "piecewise_costs",
    "competition", "long_run_costs", "long_run_competition",
    "monopoly", "monopolistic_competition", "regulation", "price_discrimination",
    "two_part_tariff", "bundling", "time_pricing", "advertising", "exhaustible_resource",
    "oligopoly", "dominant_firm", "vertical",
    "isoquants", "cost_minimization", "production_extensions", "factor_markets", "monopsony",
    "uncertainty", "auctions", "information",
)  # fmt: skip

# Animation scripts; only these animated SVGs are kept (the others are GIFs or unused).
ANIMATIONS = {
    "animate_costs": ("unit_cost_output_animated",),
    "animate_monopoly": ("monopoly_demand_shift_animated",),
    "animate_monopolistic": ("monopolistic_entry_animated",),
}


def config_for(edition: str) -> Path:
    name = (
        "econ-viz.toml" if edition == "en" else f"econ-viz.{edition}.toml"
    )
    return ROOT / "config" / name


def run(script: str, edition: str, target: Path) -> list[Path]:
    """Run one example script for one edition and return the SVG files it wrote."""
    with tempfile.TemporaryDirectory(prefix="micro-viz-manual-") as tmp:
        command = [
            sys.executable, str(EXAMPLES / f"{script}.py"),
            "--output-dir", tmp,
            "--config", str(config_for(edition)),
            "--language", edition,
            "--fonts-dir", str(FONTS),
        ]  # fmt: skip
        subprocess.run(command, check=True, capture_output=True, text=True)
        written = []
        for svg in sorted(Path(tmp).rglob("*.svg")):
            suffix = "" if edition == "en" else f".{edition}"
            destination = target / f"{svg.stem}{suffix}.svg"
            shutil.copy(svg, destination)
            written.append(destination)
        return written


def draw(
    script: str, group: str, keep: tuple[str, ...] | None = None
) -> None:
    target = OUT / group
    target.mkdir(parents=True, exist_ok=True)
    for edition in EDITIONS:
        written = run(script, edition, target)
        if keep is not None:  # drop the figures the manual does not use
            for path in written:
                if path.name.split(".")[0] not in keep:
                    path.unlink()
    if keep is None:
        shutil.copy(EXAMPLES / f"{script}.py", target / f"{group}.py")
    else:  # several scripts share the folder: each figure gets its own script
        for stem in keep:
            shutil.copy(EXAMPLES / f"{script}.py", target / f"{stem}.py")
    shutil.copy(EXAMPLES / "common.py", target / "common.py")
    print(f"{group}: {script}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "scripts", nargs="*", help="scripts to draw (default: all)"
    )
    parser.add_argument(
        "--list", action="store_true", help="list the scripts and exit"
    )
    args = parser.parse_args()
    names = list(STATIC) + list(ANIMATIONS)
    if args.list:
        print("\n".join(names))
        return 0
    unknown = set(args.scripts) - set(names)
    if unknown:
        parser.error(f"unknown script(s): {', '.join(sorted(unknown))}")
    for script in args.scripts or names:
        if script in ANIMATIONS:
            draw(script, "animation", ANIMATIONS[script])
        else:
            draw(script, script)
    return 0


if __name__ == "__main__":
    sys.exit(main())
