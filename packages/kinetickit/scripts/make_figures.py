"""Generate the manual's SVG examples with KineticKit itself."""

from __future__ import annotations

import subprocess
from pathlib import Path

import numpy as np
from glyphkit import FontLibrary, FontSource
from kinetickit import Animation, Bounds2D, Path2D, Point2D, Scene2D, Shape2D, Vec2, ease
from kinetickit.geometry.three_d import Vec3
from kinetickit.integrations.glyphkit import GlyphKitTypography
from kinetickit.scene import Camera3D, DirectionalLight3D, Scene3D, Surface3D, Text2D
from kinetickit.styles import ColorScale, Material

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "figures"


def crop_svg(
    target: Path,
    *,
    canvas: tuple[int, int],
    view_box: tuple[int, int, int, int],
) -> None:
    """Tighten an exported SVG without changing its scene coordinates."""
    canvas_width, canvas_height = canvas
    x, y, width, height = view_box
    source = target.read_text()
    original = (
        f'width="{canvas_width}" height="{canvas_height}" '
        f'viewBox="0 0 {canvas_width} {canvas_height}"'
    )
    cropped = f'width="{width}" height="{height}" viewBox="{x} {y} {width} {height}"'
    if original not in source:
        raise RuntimeError(f"unexpected SVG root in {target}")
    target.write_text(source.replace(original, cropped, 1))


def tex_font(name: str) -> Path:
    value = subprocess.check_output(["kpsewhich", name], text=True).strip()
    if not value:
        raise RuntimeError(f"TeX font not found: {name}")
    return Path(value)


def motion() -> None:
    start = Vec2(1, 1)
    end = Vec2(9, 5)
    normal = Vec2(-0.02, 0.04)
    route = Shape2D(
        id="route",
        path=Path2D.polyline(
            (start + normal, end + normal, end - normal, start - normal),
            closed=True,
        ),
        fill="#9bb8cd",
    )
    samples = tuple(
        Point2D(
            id=f"sample-{index}",
            position=start + (end - start) * ease.in_out_cubic(index / 8),
            size=4.5,
            color="#9bb8cd",
        )
        for index in range(1, 8)
    )
    endpoints = (
        Point2D(id="start", position=start, size=6, color="#e4572e"),
        Point2D(id="end", position=end, size=6, color="#e4572e"),
    )
    dot = Point2D(id="dot", position=Vec2(1, 1), size=10, color="#356f9f")
    scene = Scene2D(route, *samples, *endpoints, dot)
    scene = scene.bind({scene.camera.ref("view"): Bounds2D(Vec2(0, 0), Vec2(10, 6))})
    animation = Animation(scene, dot.animate.position.to(end, duration=2, easing=ease.in_out_cubic))
    target = OUT / "motion" / "easing.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    animation.save(target, width=600, height=300)
    crop_svg(target, canvas=(600, 300), view_box=(70, 24, 460, 252))


def typography() -> None:
    source = FontSource.path(tex_font("texgyrebonum-regular.otf"))
    library = FontLibrary.from_sources((source,))
    family = library.faces[0].family
    engine = GlyphKitTypography(library, families=(family,), size=64)
    label = Text2D(id="label", asset=engine.asset("KineticKit"), position=Vec2(1, 1), scale=0.055)
    scene = Scene2D(label)
    scene = scene.bind({scene.camera.ref("view"): Bounds2D(Vec2(0, 0), Vec2(18, 5))})
    animation = Animation(scene, label.animate.position.to(Vec2(4, 2.5), duration=1.8, easing=ease.out_cubic))
    target = OUT / "typography" / "glyphkit-text.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    animation.save(target, width=600, height=250)
    crop_svg(target, canvas=(600, 250), view_box=(20, 55, 560, 170))


def surface() -> None:
    xs = ys = np.linspace(-2, 2, 24)
    x, y = np.meshgrid(xs, ys)
    z = np.sin(np.hypot(x, y) * 2.2) / (1 + np.hypot(x, y))
    node = Surface3D.height_field(
        "surface", xs, ys, z,
        colorscale=ColorScale.viridis_like(),
        material=Material(0.4, 0.6, 0.2, 24),
    )
    scene = Scene3D(
        node,
        DirectionalLight3D(id="sun"),
        camera=Camera3D(position=Vec3(5.5, -6.5, 4.2), target=Vec3(0, 0, 0.15)),
    )
    animation = Animation(scene, scene.camera.animate.position.to(Vec3(-6, -5.5, 4.2), duration=2))
    target = OUT / "projection" / "surface.svg"
    target.parent.mkdir(parents=True, exist_ok=True)
    animation.save(target, width=600, height=420)
    crop_svg(target, canvas=(600, 420), view_box=(100, 135, 390, 210))


def main() -> None:
    motion()
    typography()
    surface()
    print("generated 3 KineticKit figures")


if __name__ == "__main__":
    main()
