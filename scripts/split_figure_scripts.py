"""Write one runnable script per figure group from a package's scripts/make_figures.py.

    python scripts/split_figure_scripts.py principle-viz mosaickit bezierkit

make_figures.py draws every figure of a manual. A reader who wants one picture should not have to read
the rest, so for each group this keeps the shared header (imports, settings, helpers) and the functions
of that group, drops the others and the command line, and ends with calls that draw the group:

    packages/<package>/figures/<group>/<group>.py

Put the script in scripts/ next to config/figures.toml and run it; the figures land in figures/.
"""

from __future__ import annotations

import ast
import sys
import tomllib
from pathlib import Path

PACKAGES = Path(__file__).resolve().parent.parent / "packages"
ROOT = PACKAGES.parent


def inline_figure_style(source: str) -> str:
    """Replace the Agora-only helper import with self-contained definitions."""
    tree = ast.parse(source)
    imported = next(
        node
        for node in tree.body
        if isinstance(node, ast.ImportFrom) and node.module == "scripts.figure_style"
    )
    lines = source.splitlines(keepends=True)
    replacement = [
        "import dataclasses\n",
        "import subprocess\n",
        "from collections.abc import Mapping\n",
        "from typing import Any\n\n",
    ]
    style = tomllib.loads((ROOT / "template" / "config" / "figures.toml").read_text())
    replacement.append(f"FIGURE_STYLE = {style!r}\n\n")
    helper_source = (ROOT / "scripts" / "figure_style.py").read_text()
    helper_tree = ast.parse(helper_source)
    for node in helper_tree.body:
        if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
            replacement.append(ast.get_source_segment(helper_source, node).rstrip() + "\n\n")
    lines[imported.lineno - 1 : imported.end_lineno] = replacement
    return "".join(lines)


def is_figures(node: ast.stmt) -> bool:
    targets = node.targets if isinstance(node, ast.Assign) else [node.target] if isinstance(node, ast.AnnAssign) else []
    return any(isinstance(t, ast.Name) and t.id == "FIGURES" for t in targets)


def registry(tree: ast.Module) -> dict[str, list[str]]:
    """group -> names of the functions that draw it, read from the FIGURES dict."""
    for node in tree.body:
        if is_figures(node):
            groups: dict[str, list[str]] = {}
            for key, value in zip(node.value.keys, node.value.values, strict=True):
                names = [e.id for e in value.elts] if isinstance(value, ast.List) else [value.id]
                group = key.value.split("/")[0]  # mosaickit keys are "group/name"
                groups.setdefault(group, []).extend(names)
            return groups
    raise SystemExit("no FIGURES dict")


def split(package: str) -> None:
    path = PACKAGES / package / "scripts" / "make_figures.py"
    source = path.read_text()
    lines = source.splitlines(keepends=True)
    tree = ast.parse(source)
    groups = registry(tree)
    drawn = {name for names in groups.values() for name in names}
    functions = {n.name: n for n in tree.body if isinstance(n, ast.FunctionDef)}
    for group, names in groups.items():
        drop = []
        for node in tree.body:
            if isinstance(node, ast.FunctionDef) and (node.name in drawn - set(names) or node.name == "main"):
                drop.append(node)
            elif is_figures(node):
                drop.append(node)
            elif isinstance(node, ast.If) and "__name__" in ast.unparse(node.test):
                drop.append(node)
        keep = [True] * len(lines)
        for node in drop:
            start = node.lineno - 1 - len(getattr(node, "decorator_list", []))
            for k in range(start, node.end_lineno):
                keep[k] = False
        body = "".join(line for line, k in zip(lines, keep, strict=True) if k).rstrip("\n") + "\n"
        body = inline_figure_style(body)
        calls = []
        for name in names:
            args = {a.arg for a in functions[name].args.args + functions[name].args.kwonlyargs}
            calls.append(f"    {name}({'compile_pdf=True' if 'compile_pdf' in args else ''})")
        if "set_edition" in functions:  # one set of figures per language, like make_figures.py
            if package == "principle-viz":
                tail = [
                    "    register_fonts()",
                    "    use_house_colours()",
                    "    for edition in EDITIONS:",
                    "        with use_config(set_edition(edition)):",
                ] + ["        " + c for c in calls] + [
                    "    for path in OUT.rglob(\"*.svg\"):",
                    "        normalize_svg(path)",
                ]
            else:
                tail = ["    register_fonts()", "    for edition in EDITIONS:", "        set_edition(edition)"] + ["    " + c for c in calls]
        else:
            tail = calls
        text = body + '\n\nif __name__ == "__main__":\n' + "\n".join(tail) + "\n"
        compile(text, f"{package}/{group}", "exec")
        out = PACKAGES / package / "figures" / group / f"{group}.py"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text)
        print(f"  {out.relative_to(PACKAGES.parent)}")


if __name__ == "__main__":
    for name in sys.argv[1:] or ["principle-viz", "mosaickit", "bezierkit"]:
        split(name)
