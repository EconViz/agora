from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from scripts.figure_style import (  # noqa: E402
    FIGURE_STYLE,
    LocalizedMatplotlibRenderer,
    mosaickit_config,
    normalize_svg,
    register_fonts,
    scaled_mosaickit_config,
)


class FigureStyleTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        register_fonts()

    def test_point_labels_use_the_same_size_as_other_labels(self) -> None:
        from mosaickit import Canvas, CanvasSpec, PointLabelLayer, TextLayer

        config = mosaickit_config(text_size=8, note_size=7)
        canvas = Canvas(CanvasSpec(), config=config)
        canvas.add(TextLayer((1, 1), "ordinary"))
        canvas.add(PointLabelLayer((2, 2), "point"))

        result = canvas.render()
        try:
            sizes = {text.get_text(): text.get_fontsize() for text in result.axes.texts}
        finally:
            result.close()

        self.assertEqual(sizes["ordinary"], 8)
        self.assertEqual(sizes["point"], 8)

    def test_cjk_figures_use_the_manual_serif_families(self) -> None:
        self.assertEqual(FIGURE_STYLE["fonts"]["cjk"]["zh-TW"], "Noto Serif TC")
        self.assertEqual(FIGURE_STYLE["fonts"]["cjk"]["zh-CN"], "Noto Serif SC")

    def test_localized_renderer_translates_without_patching_matplotlib_renderer(self) -> None:
        from mosaickit import Canvas, CanvasSpec, TextLayer

        canvas = Canvas(CanvasSpec(), config=mosaickit_config(text_size=8, note_size=7))
        canvas.add(TextLayer((1, 1), "Demand"))
        renderer = LocalizedMatplotlibRenderer({"Demand": "需求"})

        result = canvas.render(renderer=renderer)
        try:
            labels = [text.get_text() for text in result.axes.texts]
        finally:
            result.close()

        self.assertEqual(labels, ["需求"])

    def test_scaled_config_preserves_theme_text_size_relationships(self) -> None:
        from principle_viz import PlotTheme

        config = scaled_mosaickit_config(PlotTheme().to_mosaickit(), scale=1.5)

        self.assertEqual(config.role_overrides["axes"].text.size, 16.5)
        self.assertEqual(
            config.role_overrides["principle.market.movement"].text.size,
            15,
        )

    def test_svg_normalization_removes_generated_line_end_spaces(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "figure.svg"
            path.write_text("<path d=\"M 0 1 \nL 2 3 \n\"/>  \n")

            normalize_svg(path)

            self.assertEqual(path.read_text(), "<path d=\"M 0 1\nL 2 3\n\"/>\n")


if __name__ == "__main__":
    unittest.main()
