#import "/template/manual.typ": *

= Themes and configuration <sec-themes>

== Style bundles and themes

#api(("StyleBundle",), syntax: [#raw("StyleBundle(stroke=None, fill=None, marker=None, text=None, legend=None)")])[
  One sparse style per slot. A slot holding the wrong type raises
  `ConfigurationError`. `merged_over(base)` merges slot by slot
  (@def-merge).
]

#api(("Theme",), syntax: [#raw("Theme(name, roles)")])[
  A theme name and an immutable mapping from role names to bundles. Role
  names are non-empty dotted strings (`"axes"`, `"axes.note"`,
  `"mypkg.boundary"`).
  `with_roles(**patch)` returns a theme with each patched role merged over
  its old bundle; since keyword names cannot contain dots, pass dotted
  roles as `with_roles(**{"mypkg.line": bundle})`.
  `resolve(role, fallback_category=...)` resolves a role against the theme
  alone.
]

#tbl(caption: [The `default` theme])[
  #booktabs(
    columns: (auto, 1fr),
    header: ([Role], [Bundle]),
    [`primary`], [stroke `blue`],
    [`secondary`], [stroke `red`],
    [`accent`], [stroke `teal`],
    [`guide`], [stroke `grey-400`, dashed],
    [`axes`], [stroke `grey-800`, width 1],
    [`axes.note`], [text 9 pt, `grey-600`],
    [`canvas`], [fill `white`, opacity 1 (the background)],
  )
] <tab-default-theme>

Every other value comes from the primitive defaults of @tab-primitive. The
theme is `mosaickit.themes.default`.

== Role resolution

A layer's role is resolved through its ancestor roles and then through the
fallback category for its layer type. For each field, the fallback applies
only when neither the role nor any ancestor supplies a value.

#definition(name: [Role chain])[
  The _chain_ of a role $rho = rho_1.rho_2 dots.c rho_m$ with fallback
  category $phi$ is the sequence
  $ kappa(rho) = (rho_1 dots.c rho_m, thin rho_1 dots.c rho_(m-1), thin dots, thin rho_1, thin phi), $
  most specific first, with a repeated key kept only at its first place.
] <def-chain>

For example `"axes.note"` on a text layer has the chain
(`axes.note`, `axes`, `text`). The fallback categories are `primary`
(paths, groups), `region` (fills), `point` (markers), `text` (text, labels,
marks, notes, braces), `annotation` (arrows) and `legend`.

#theorem(name: [Resolution order])[
  Let a layer with explicit styles $E$ and role chain
  $kappa = (k_1, dots, k_n)$ be drawn on a canvas with role overrides $C$,
  under a configuration with role overrides $G$ and theme roles $T$, and let
  $D$ be the primitive defaults. Then each field of the layer's resolved
  style is the first value that is not `None` in the sequence
  $ E, quad C[k_1], dots, C[k_n], quad G[k_1], dots, G[k_n], quad
    T[k_1], dots, T[k_n], quad D, $
  where a missing role counts as the empty bundle.
] <thm-resolution>

#corollary(name: [Overrides beat specificity])[
  A canvas or configuration override of a general role takes precedence over
  the theme's value for a more specific role: if $G["text"]$ sets a text size
  and no source before it in @thm-resolution does, a text layer with role
  `axes.note` gets that size, not the theme's 9 pt.
] <cor-override>

The figures in this manual use @cor-override. They override the text size of
`text`, `axes` and `axes.note` together because overriding `text` alone would
also enlarge the notes.

#changed("0.2.0", label: "resolve")[`themes.resolve` accepts `overrides`, applied in order after the theme]

== Registering domain roles

#api(("ThemeRegistry",), syntax: [#raw("ThemeRegistry()")])[
  A registry of themes, holding `default` from the start. `register(theme)`
  adds one (a taken name raises `ConfigurationError`), `get(name)` looks one
  up, and `register_roles(name, roles)` merges dotted domain roles into a
  registered theme and returns it; an undotted role raises
  `ConfigurationError`, so domain packages cannot shadow the built-in roles.
]

#api(("RolePack", "expand_roles"), syntax: [#raw("expand_roles(pack) -> dict[str, StyleBundle]")])[
  A typed representation of a domain package's roles. A `RolePack` is a
  dataclass with a class variable `_namespace`; each field that is not `None`
  becomes the role `namespace.field`, with underscores in the field name
  turned into dots.
]

```python
from dataclasses import dataclass
from typing import ClassVar
from mosaickit import Stroke, StyleBundle, Theme, expand_roles
from mosaickit.themes import default

@dataclass(frozen=True)
class MyRoles:
    _namespace: ClassVar[str] = "mypkg"
    line: StyleBundle | None = StyleBundle(stroke=Stroke(color="blue", width=2))
    line_dashed: StyleBundle | None = None

roles = expand_roles(MyRoles())        # {"mypkg.line": ...}
mytheme = Theme("mypkg", {**default.roles, **roles})
```

== Configuration <sec-config>

#api(("Config",), syntax: [
  #raw("Config(theme=default, canvas_spec=CanvasSpec(), renderer=\"matplotlib\",") \
  #raw("       role_overrides={}, palette=DEFAULT_PALETTE)")
])[
  Runtime defaults for new canvases: the theme, the specification, the
  renderer (a name or a `Renderer`), role overrides applied after the theme
  ($G$ in @thm-resolution) and the palette.
  #changed("0.3.0")[`Config.palette` added, defaulting to `DEFAULT_PALETTE`]
]

#api(("use_config",), syntax: [#raw("with use_config(config): ...")])[
  Makes `config` the active configuration inside the block. A context
  variable stores the value, so each thread and asynchronous task sees its
  own configuration. Arguments passed to `Canvas` always take precedence.
]

#api(("Config.load", "Config.from_dict"), syntax: [
  #raw("Config.load(path)") \
  #raw("Config.from_dict(data, *, source=\"<dict>\")")
])[
  Reads a strict TOML configuration. Top-level keys are `theme` (only
  `"default"`; custom themes are passed in Python), `canvas` (fields of
  `CanvasSpec`), `renderer` (only `"matplotlib"`), `palette` and `styles`.
  Any other key, unknown style, bad value or unreadable file raises
  `ConfigurationError` naming the file and the key.
]

```toml
[canvas]
x_range = [0, 20]
dpi = 150

[palette]
blue = "#0072B2"     # override a default color
accent = "#984EA3"   # add a new name

[styles."mypkg.boundary".stroke]
color = "accent"     # a palette name or a "#hex" value
width = 2
dash = "dashed"
```

The `[palette]` table is merged over `DEFAULT_PALETTE`, so overriding `blue`
there recolors `primary` and everything else that names `blue`. Style
`color` and `edge_color` values may be palette names; an unknown name
raises `ConfigurationError` naming the file and key when the file is
loaded, before any canvas renders.

#changed("0.3.0", label: "Config.load")[TOML accepts a `[palette]` table, and style colors may be palette names, checked when the file is loaded]
