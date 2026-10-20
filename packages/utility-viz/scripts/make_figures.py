"""Draw the manual's figures by running the manual's own examples.

Every figure of the manual sits right after the code that draws it, and this script runs exactly
that code, so the figure is what the printed code produces. It reads `chapters/<edition>/*.typ`,
pairs each `#fig(...)` with the last Python example before it, runs the example, and saves the
picture as `figures/<group>/<name>.svg`.

    uv run python scripts/make_figures.py            # all figures
    uv run python scripts/make_figures.py models     # one group
    uv run python scripts/make_figures.py --list     # list figure names

What the script adds to the examples, and nothing else:

* the working directory holds `manual.toml` (the settings the examples load) and nothing else;
* every `save()` is redirected to the figure's SVG, cropped to its content on a white page;
* the examples do not pin a typeface, so the figures are set in TeX Gyre Pagella, the manual's;
* an animation example saves a GIF; the figure shows four frames of it (see FRAMES).

Next to each SVG the script also writes the code it ran, `<name>.py`, which the website offers to download.

The three editions each carry the example in their own language. When the code of an edition
differs from the English one (a translated title, a CJK font) it gets its own figure,
`<name>.zh-TW.svg`; otherwise all editions share `<name>.svg`.
"""

from __future__ import annotations

import argparse
import ast
import dataclasses
import os
import re
import shutil
import subprocess
import sys
import tempfile
import textwrap
import tomllib
import warnings
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

from matplotlib import font_manager  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
CONFIG = tomllib.loads((ROOT / "config" / "figures.toml").read_text())
OUT = ROOT / CONFIG["output"]["dir"]
FONT = CONFIG["fonts"]["family"]
EDITIONS = ["en", "zh-TW", "zh-CN"]

# An animation figure shows four frames of the GIF its example saves: these values of `frames`.
FRAMES = {
    "animation/price_sweep": [1.0, 2.0, 4.0, 6.0],
    "animation/income_sweep": [8.0, 14.0, 20.0, 26.0],
    "animation/parameter_sweep": [0.2, 0.4, 0.6, 0.8],
}

# Figures whose script is too long to print: it lives in scripts/scenes/<name>.<edition>.py.
SCENES = ["consumer/demand", "consumer/hicks", "consumer/edgeworth"]

FIG = re.compile(r'^#fig\("/figures/(?P<name>[\w/]+?)(?P<suffix>\.zh-[A-Z]+)?\.svg"', re.M)
BLOCK = re.compile(r"^[ \t]*(?:#example\(\[)?```python\n(.*?)\n[ \t]*```", re.S | re.M)


# ---------------------------------------------------------------------------
# Reading the chapters
# ---------------------------------------------------------------------------


def examples(edition: str) -> dict[str, str]:
    """figure name -> the code printed right before it, in this edition's chapters."""
    found: dict[str, str] = {}
    for chapter in sorted((ROOT / "chapters" / edition).glob("*.typ")):
        text = chapter.read_text()
        start = 0
        for fig in FIG.finditer(text):
            blocks = list(BLOCK.finditer(text, start, fig.start()))
            start = fig.end()
            if blocks:
                found[fig["name"]] = textwrap.dedent(blocks[-1].group(1))
    for name in SCENES:  # these figures are drawn from MosaicKit layers; the manual prints the API call instead
        found[name] = (ROOT / "scripts" / "scenes" / f"{name.split('/')[-1]}.{edition}.py").read_text()
    return found


def program(code: str) -> str:
    """The code without its comments and docstrings, to compare editions by what they do."""
    tree = ast.parse(code)
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)) and ast.get_docstring(node):
            node.body = node.body[1:] or [ast.Pass()]
    return ast.unparse(tree)


def check_settings() -> None:
    """Every edition prints manual.toml in full, so the file the examples load is the file the manual shows.

    The comments are in the edition's language, so the editions are compared without them.
    """
    def settings(text: str) -> list[str]:
        return [re.sub(r"\s+# .*$", "", line) for line in text.splitlines() if not line.lstrip().startswith("#")]

    shown = settings((ROOT / "config" / "manual.toml").read_text())
    for edition in EDITIONS:
        chapter = (ROOT / "chapters" / edition / "09-themes.typ").read_text()
        block = re.search(r"<sec-manual-toml>.*?```toml\n(.*?)\n```", chapter, re.S)
        if not block or settings(block.group(1)) != shown:
            raise SystemExit(f"{edition}: 09-themes.typ does not print config/manual.toml as it is")


def plan() -> dict[str, dict[str, str]]:
    """figure name -> {file suffix: code}. One entry when the editions share a figure."""
    per_edition = {edition: examples(edition) for edition in EDITIONS}
    result: dict[str, dict[str, str]] = {}
    for name, code in per_edition["en"].items():
        variants = {"": code}
        for edition in EDITIONS[1:]:
            other = per_edition[edition].get(name)
            if other is not None and program(other) != program(code):
                variants[f".{edition}"] = other
        result[name] = variants
    for edition in EDITIONS[1:]:
        extra = set(per_edition[edition]) - set(per_edition["en"])
        if extra:
            raise SystemExit(f"{edition} has figures the English edition lacks: {sorted(extra)}")
    return result


# ---------------------------------------------------------------------------
# Running an example
# ---------------------------------------------------------------------------


def strip(frames: list[Path], target: Path, gap: float = 12.0) -> None:
    """Place the SVG files side by side in one SVG (sizes in points), keeping every drawing vector.

    Each file's element ids are prefixed with its position, since Matplotlib reuses ids across files.
    """
    pieces, x, height = [], 0.0, 0.0
    for index, path in enumerate(frames):
        svg = path.read_text()
        root = re.search(r"<svg\b[^>]*>", svg)
        width_pt = float(re.search(r'width="([\d.]+)pt"', root.group(0)).group(1))
        height_pt = float(re.search(r'height="([\d.]+)pt"', root.group(0)).group(1))
        inner = svg[root.end() : svg.rindex("</svg>")]
        for ident in set(re.findall(r'\bid="([^"]+)"', inner)):
            inner = inner.replace(f'id="{ident}"', f'id="f{index}-{ident}"')
            inner = inner.replace(f"url(#{ident})", f"url(#f{index}-{ident})")
            inner = inner.replace(f'href="#{ident}"', f'href="#f{index}-{ident}"')
        pieces.append(f'<g transform="translate({x:.2f},0)">{inner}</g>')
        x, height = x + width_pt + gap, max(height, height_pt)
    width = x - gap
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
        f'width="{width:.2f}pt" height="{height:.2f}pt" viewBox="0 0 {width:.2f} {height:.2f}">'
        + "".join(pieces)
        + "</svg>\n"
    )


def register_fonts() -> None:
    """TeX Gyre Pagella from the TeX distribution, for text and for mathtext."""
    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"], capture_output=True, text=True, check=True
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        return
    for rel in CONFIG["fonts"]["texmf_files"]:
        path = Path(texmf) / rel
        if path.exists():
            font_manager.fontManager.addfont(str(path))
    matplotlib.rcParams.update(
        {
            "font.family": [FONT],
            "mathtext.fontset": "custom",
            "mathtext.rm": FONT,
            "mathtext.it": f"{FONT}:italic",
            "mathtext.bf": f"{FONT}:bold",
        }
    )
    # MosaicKit text layers whose theme role names no family fall back to DejaVu Sans; use the manual's.
    from mosaickit import TextStyle
    from mosaickit.themes import resolution

    base = resolution.PRIMITIVE_DEFAULT
    resolution.PRIMITIVE_DEFAULT = dataclasses.replace(
        base, text=dataclasses.replace(base.text or TextStyle(), family=FONT)
    )


class Recorder:
    """Redirects what an example saves into the figure file, and notes what an Animator was given."""

    def __init__(self, target: Path, savefig):
        self.target, self.saved, self.animators, self.savefig = target, 0, [], savefig

    def write(self, figure) -> None:
        self.saved += 1
        if self.saved > 1:
            raise SystemExit(f"{self.target.name}: the example saves more than one picture")
        self.target.parent.mkdir(parents=True, exist_ok=True)
        self.savefig(
            figure, self.target, format="svg", bbox_inches="tight", pad_inches=0.04, facecolor="white",
            metadata={"Date": None},
        )


def run(code: str, target: Path, name: str) -> None:
    """Run one example in an empty directory that holds manual.toml, saving its picture to *target*."""
    from matplotlib.figure import Figure
    from mosaickit.rendering.matplotlib.renderer import MatplotlibRenderer
    from utility_viz import Config
    from utility_viz.core.animation import Animator

    originals = (MatplotlibRenderer.save, Figure.savefig, Animator.__init__, Animator.save)
    recorder = Recorder(target, originals[1])

    def save(self, result, path, options):
        recorder.write(result.figure)
        return [Path(path)]

    def savefig(self, fname, *args, **kwargs):
        if str(fname).endswith((".png", ".pdf", ".svg")):
            return recorder.write(self)
        return originals[1](self, fname, *args, **kwargs)

    def init(self, factory, frames):
        recorder.animators.append((factory, list(frames)))
        originals[2](self, factory, frames)

    MatplotlibRenderer.save, Figure.savefig, Animator.__init__ = save, savefig, init
    Animator.save = lambda self, *args, **kwargs: None  # the GIF is not part of the manual
    cwd = os.getcwd()
    try:
        with tempfile.TemporaryDirectory() as tmp:
            shutil.copy(ROOT / "config" / "manual.toml", tmp)
            os.chdir(tmp)
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                exec(compile(code, name, "exec"), {"__name__": "__manual__"})
                if recorder.animators:
                    factory, _ = recorder.animators[0]
                    files = []
                    for index, value in enumerate(FRAMES[name]):
                        recorder.target, recorder.saved = Path(tmp) / f"frame{index}.svg", 0
                        factory(value).save("frame.png")
                        files.append(recorder.target)
                    strip(files, target)
                    recorder.target, recorder.saved = target, 1
    finally:
        os.chdir(cwd)
        MatplotlibRenderer.save, Figure.savefig, Animator.__init__, Animator.save = originals
        Config.reset()
    if recorder.saved != 1:
        raise SystemExit(f"{name}: the example saved {recorder.saved} pictures, not one")


# ---------------------------------------------------------------------------


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("only", nargs="*", help="figure names or group prefixes")
    parser.add_argument("--list", action="store_true", help="list figure names")
    args = parser.parse_args()

    check_settings()
    figures = plan()
    if args.list:
        for name, variants in figures.items():
            print(name, *(suffix or "(shared)" for suffix in variants))
        return 0
    selected = [
        name for name in figures
        if not args.only or any(name == o or name.startswith(o.rstrip("/") + "/") for o in args.only)
    ]
    if not selected:
        print(f"no figure matches {args.only}", file=sys.stderr)
        return 1
    register_fonts()
    print(f"writing {sum(len(figures[n]) for n in selected)} figure(s):")
    for name in selected:
        for suffix, code in figures[name].items():
            target = OUT / f"{name}{suffix}.svg"
            run(code, target, name)
            target.with_suffix(".py").write_text(code.rstrip("\n") + "\n")  # the website offers it as a download
            print(f"  {target.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
