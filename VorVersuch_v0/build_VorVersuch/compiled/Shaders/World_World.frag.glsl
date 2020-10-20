#version 450
#include "compiled.inc"
in vec3 normal;
out vec4 fragColor;
uniform vec3 backgroundCol;
void main() {
	fragColor.rgb = backgroundCol;
	fragColor.a = 0.0;
}
