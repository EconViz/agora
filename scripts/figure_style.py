"""Shared visual style and public rendering adapters for Agora figures."""

from __future__ import annotations

import dataclasses
import subprocess
import tomllib
from collections.abc import Mapping
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
FIGURE_STYLE = tomllib.loads((ROOT / "template" / "config" / "figures.toml").read_text())


def register_fonts() -> None:
    """Register the manual's bundled and TeX fonts with Matplotlib."""
    import matplotlib
    from matplotlib import font_manager

    try:
        texmf = subprocess.run(
            ["kpsewhich", "-var-value", "TEXMFDIST"],
            capture_output=True,
            text=True,
            check=True,
        ).stdout.strip()
    except (OSError, subprocess.CalledProcessError):
        texmf = ""

    candidates = [Path(texmf) / rel for rel in FIGURE_STYLE["fonts"]["texmf_files"]]
    font_roots = (ROOT / "fonts", ROOT.parents[1] / "fonts")
    candidates.extend(
        root / filename
        for root in font_roots
        for files in FIGURE_STYLE["fonts"]["files"].values()
        for filename in files
    )
    for path in candidates:
        if path.is_file():
            font_manager.fontManager.addfont(str(path))

    latin = FIGURE_STYLE["fonts"]["latin"]
    matplotlib.rcParams.update(
        {
            "font.family": [latin],
            "mathtext.fontset": "custom",
            "mathtext.rm": latin,
            "mathtext.it": f"{latin}:italic",
            "mathtext.bf": f"{latin}:bold",
            "mathtext.cal": f"{latin}:italic",
            "mathtext.sf": latin,
            "mathtext.tt": latin,
        }
    )


def font_family(edition: str = "en") -> str:
    return FIGURE_STYLE["fonts"]["cjk"].get(edition, FIGURE_STYLE["fonts"]["latin"])


def normalize_svg(path: str | Path) -> None:
    """Remove renderer-only line-end spaces while preserving SVG content."""
    path = Path(path)
    lines = path.read_text().splitlines()
    path.write_text("\n".join(line.rstrip() for line in lines) + "\n")


def mosaickit_config(
    *,
    edition: str = "en",
    text_size: float | None = None,
    note_size: float | None = None,
    renderer: Any = "matplotlib",
):
    """Build a MosaicKit config without modifying its private theme defaults."""
    from mosaickit import Config, StyleBundle, TextStyle

    text_size = text_size if text_size is not None else FIGURE_STYLE["text"]["size"]
    note_size = note_size if note_size is not None else FIGURE_STYLE["text"]["note"]
    family = font_family(edition)
    ink = FIGURE_STYLE["colors"]["ink"]
    return Config(
        renderer=renderer,
        role_overrides={
            "text": StyleBundle(text=TextStyle(size=text_size, color=ink, family=family)),
            "axes.note": StyleBundle(text=TextStyle(size=note_size, color=ink, family=family)),
        },
    )


def scaled_mosaickit_config(
    theme,
    *,
    scale: float,
    edition: str = "en",
    renderer: Any = "matplotlib",
):
    """Scale a theme's text roles while retaining their relative sizes."""
    from mosaickit import Config, StyleBundle, TextStyle

    family = font_family(edition)
    ink = FIGURE_STYLE["colors"]["ink"]
    overrides = {
        "text": StyleBundle(text=TextStyle(size=12 * scale, color=ink, family=family)),
        "axes.note": StyleBundle(text=TextStyle(size=9 * scale, color=ink, family=family)),
    }
    for role, bundle in theme.roles.items():
        if bundle.text is not None and bundle.text.size is not None:
            overrides[role] = StyleBundle(
                text=dataclasses.replace(
                    bundle.text,
                    size=bundle.text.size * scale,
                    family=family,
                )
            )
    return Config(renderer=renderer, role_overrides=overrides)


def localize(value: Any, table: Mapping[str, str]) -> Any:
    """Recursively copy a render value, translating its strings."""
    if isinstance(value, str):
        return table.get(value, value)
    if dataclasses.is_dataclass(value) and not isinstance(value, type):
        changes = {
            field.name: translated
            for field in dataclasses.fields(value)
            if (translated := localize(getattr(value, field.name), table))
            != getattr(value, field.name)
        }
        return dataclasses.replace(value, **changes) if changes else value
    if isinstance(value, tuple):
        if hasattr(value, "_fields"):
            return type(value)(*(localize(item, table) for item in value))
        return tuple(localize(item, table) for item in value)
    if isinstance(value, list):
        return [localize(item, table) for item in value]
    if isinstance(value, dict):
        return {key: localize(item, table) for key, item in value.items()}
    return value


class LocalizedMatplotlibRenderer:
    """Translate render inputs through MosaicKit's public renderer protocol."""

    name = "localized-matplotlib"

    def __init__(
        self,
        labels: Mapping[str, str] | None = None,
        *,
        family: str | None = None,
    ) -> None:
        from mosaickit.rendering.matplotlib.renderer import MatplotlibRenderer

        self.labels = dict(labels or {})
        self.family = family
        self._renderer = MatplotlibRenderer()

    def render(self, scene, context):
        import matplotlib

        rc = {"font.family": [self.family]} if self.family else {}
        with matplotlib.rc_context(rc):
            return self._renderer.render(localize(scene, self.labels), localize(context, self.labels))

    def render_grid(self, grid, cache):
        from mosaickit import Canvas, CanvasGrid
        from mosaickit.canvas import Span

        starts: dict[tuple[int, int], Any] = {}
        covered: set[tuple[int, int]] = set()
        for placement in grid.placements:
            source = placement.canvas
            canvas = Canvas(
                localize(source.spec, self.labels),
                localize(source.theme, self.labels),
                localize(source.config, self.labels),
                renderer=self,
                role_overrides=localize(source.role_overrides, self.labels),
            ).extend(localize(source.snapshot().layers, self.labels))
            cell = Span(canvas, rows=placement.rows, cols=placement.cols)
            starts[(placement.row, placement.col)] = cell
            for row in range(placement.row, placement.row + placement.rows):
                for col in range(placement.col, placement.col + placement.cols):
                    if row != placement.row or col != placement.col:
                        covered.add((row, col))
        matrix = []
        for row in range(grid.rows):
            cells = []
            for col in range(grid.cols):
                if (row, col) in covered:
                    continue
                cells.append(starts.get((row, col)))
            matrix.append(cells)
        translated = CanvasGrid(matrix, links=localize(grid.links, self.labels))
        import matplotlib

        rc = {"font.family": [self.family]} if self.family else {}
        with matplotlib.rc_context(rc):
            return self._renderer.render_grid(translated, cache)

    def save(self, result, target, options):
        return self._renderer.save(result, target, options)
