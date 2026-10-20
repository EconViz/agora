#import "/template/manual.typ": *

= Interpolation and transforms <sec-kinetic-interpolation>

== Scalars, vectors, colours, and steps

For real values, KineticKit uses exact-endpoint linear interpolation
$ L(a,b,u) = (1-u)a + u b. $
Vectors and colours apply this componentwise. Discrete values switch at a configured threshold.

== Angles and affine transforms

Angles use the shortest signed difference
$ Delta = ((b-a+pi) mod 2pi)-pi, quad theta(u)=a+u Delta. $
A 2D transform combines translation, rotation, scale, and shear in a $3 times 3$ homogeneous matrix. Matrix composition is ordinary multiplication, so order matters: rotating after translating is not the same as translating after rotating.

== Quaternion rotation

A unit quaternion $q=(w,x,y,z)$ represents a 3D rotation. Axis-angle input with unit axis $v$ and angle $theta$ becomes
$ q=(cos(theta/2), v sin(theta/2)). $
For endpoints $q_0,q_1$, KineticKit flips $q_1$ when their dot product is negative so interpolation takes the short arc. With $theta=arccos(q_0 dot q_1)$,
$ "slerp"(q_0,q_1,u) = (sin((1-u)theta)/sin theta) q_0 + (sin(u theta)/sin theta) q_1. $
Nearly parallel quaternions use normalised linear interpolation for numerical stability.

#api(("Quaternion",))[A validated unit quaternion for 3D rotation. Construction normalises finite, nonzero components.]
#api(("Transform2D",))[An immutable 2D affine transform combining translation, rotation, scale, and shear.]
#api(("Transform3D",))[An immutable homogeneous 3D transform used for translation, rotation, scale, and composition.]

== Custom interpolators

Custom property types participate by registering an interpolator. The registry is resolved when a motion is compiled, so missing interpolation fails before frame export.
