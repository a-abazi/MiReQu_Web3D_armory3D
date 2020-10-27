#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec3 wnormal;
out vec4 fragColor[2];
uniform vec3 param_RGB;
void main() {
vec3 n = normalize(wnormal);
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float emission;
	vec3 RGB_Color_res = param_RGB;
	basecol = (RGB_Color_res * 1000.0);
	roughness = 0.0;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 1.0;
	emission = 1.0;
	if (!gl_FrontFacing) n *= -1;
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	uint matid = 0;
	if (emission > 0) { basecol *= emission; matid = 1; }
	fragColor[0] = vec4(n.xy, roughness, packFloatInt16(metallic, matid));
	fragColor[1] = vec4(basecol, packFloat2(occlusion, specular));
}
