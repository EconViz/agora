#import "/template/manual.typ": *

= Path, mesh, and surface morphing <sec-kinetic-morphing>

== Correspondence first

Morphing requires correspondence: the interpolator must know which source element becomes which target element. KineticKit validates this relation before animation.

== Paths

Compatible paths interpolate command coordinates directly. When paths need normalisation, curved segment length is approximated, split parameters are chosen by arc-length fraction, and de Casteljau subdivision adds corresponding segments. For matched control points $P_i$ and $Q_i$,
$ R_i(u)=(1-u) P_i+u Q_i. $
This preserves exact endpoints and command topology at every intermediate frame.

== Meshes

Meshes with matching faces interpolate vertex arrays componentwise. If $V_0,V_1 in RR^(n times 3)$ share topology, then $V(u)=(1-u) V_0+u V_1$. An explicit correspondence can permute vertices when semantic identity differs from storage order.

== Height-field surfaces

A regular surface samples $z=f(x,y)$ on a grid. Morphing keeps the $x,y$ lattice fixed and interpolates height and optional colour data. Camera motion remains independent, so a surface morph and orbit can run concurrently with `with_()`.

#api(("Path2D",))[An immutable sequence of exact move, line, Bézier, and close commands used by 2D paths and shapes.]
#api(("MeshData",))[Validated vertices, faces, and optional correspondence data for mesh interpolation.]
#api(("SurfaceGrid",))[A regular $x,y$ lattice with height and optional colour samples for surface morphing.]

== Morph or transition

Use a `SceneTransition` cross-fade only when the objects are genuinely different; use morphing when intermediate geometry has meaning.
