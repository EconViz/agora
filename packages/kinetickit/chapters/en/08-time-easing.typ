#import "/template/manual.typ": *

= Time, easing, and motion algebra <sec-kinetic-time>

== Normalised segment time

An animation property changes over a segment $[t_0,t_0+D]$. KineticKit first normalises time,
$ u = "clamp"((t-t_0)/D, 0, 1), $
then evaluates an easing function $e(u)$, and finally asks the property's interpolator for the value at progress $e(u)$.

== Easing families

Linear easing is $e(u)=u$. Polynomial ease-in uses $u^n$; ease-out reflects it as $1-(1-u)^n$; ease-in-out joins scaled copies at $u=1/2$. Sine, exponential, circular, back, elastic, and bounce families follow the same endpoint contract $e(0)=0$, $e(1)=1$.

#api(("ease",))[
  Provides named easing functions and cubic Bézier easing. Overshooting functions may leave $[0,1]$ internally; exact property endpoints are still returned at segment boundaries.
]

== Cubic Bézier timing

A cubic Bézier timing curve with controls $(x_1,y_1)$ and $(x_2,y_2)$ is
$ B(t) = (1-t)^3(0,0) + 3(1-t)^2t(x_1,y_1) + 3(1-t) t^2(x_2,y_2) + t^3(1,1). $
For a requested time $u$, the easing value is the $y$ coordinate whose $x$ coordinate equals $u$.

== Composition

For `a.then(b, gap=g)`, duration is $D_a+g+D_b$. For `a.with_(b, offset=o)`, it is $max(D_a,o+D_b)$. Repetition multiplies duration; reversal samples child time $D-t$; trimming maps a new interval back into the child interval. These operations build immutable motion trees before compilation.

@fig-kinetic-motion is the exported result of this pipeline, not a hand-drawn trajectory.
