#import "/template/manual.typ": *

= 插值与坐标变换 <sec-kinetic-interpolation>

== 纯量、向量、颜色与离散值

实数使用保留精确端点的线性插值 $L(a, b, u) = (1 - u) a + u b$；向量与颜色逐分量应用，离散值则在指定阈值切换。

== 角度与仿射变换

角度采最短有号差
$ Delta=((b-a+pi) mod 2pi)-pi, quad theta(u)=a+u Delta. $
2D 变换把平移、旋转、缩放与剪切组成 $3 times 3$ 齐次矩阵。矩阵乘法的次序有意义，先平移再旋转并不等于先旋转再平移。

== 四元数旋转

单位轴 $v$ 与角度 $theta$ 转换成 $q = (cos(theta / 2), v sin(theta / 2))$。若 $q_0 dot q_1 < 0$，先反转 $q_1$，以沿较短的旋转路径移动。令 $theta = arccos(q_0 dot q_1)$，则
$ "slerp"(q_0,q_1,u)=(sin((1-u)theta)/sin theta) q_0+(sin(u theta)/sin theta) q_1. $
两端几乎平行时改用归一化线性插值，避免数值不稳定。

== 几何值与验证

#api(("Quaternion",))[用于 3D 旋转的单位四元数；创建时会验证并归一化有限、非零的分量。]
#api(("Transform2D",))[不可变的 2D 仿射变换，组合平移、旋转、缩放与剪切。]
#api(("Transform3D",))[不可变的 3D 齐次变换，用于平移、旋转、缩放与变换组合。]

== 自定义插值器

自定义属性类型可以向注册表（registry）注册插值器。KineticKit 在编译动作时解析类型与插值器；缺少实现会在输出任何帧之前失败，不会等动画运行到一半才出错。
