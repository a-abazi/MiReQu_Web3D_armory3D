#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec3 wnormal;
out vec4 fragColor[2];
void main() {
vec3 n = normalize(wnormal);
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float emission;
	const float MixShader_fac = 0.5;
	const float MixShader_fac_inv = 1.0 - MixShader_fac;
	basecol = ((vec3(0.0, 1.0, 0.9348044395446777) * 1000.0) * MixShader_fac_inv + vec3(0.8) * MixShader_fac);
	roughness = (0.0 * MixShader_fac_inv + 0.0 * MixShader_fac);
	metallic = (0.0 * MixShader_fac_inv + 0.0 * MixShader_fac);
	occlusion = (1.0 * MixShader_fac_inv + 1.0 * MixShader_fac);
	specular = (1.0 * MixShader_fac_inv + 1.0 * MixShader_fac);
	emission = (1.0 * MixShader_fac_inv + 0.0 * MixShader_fac);
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	uint matid = 0;
	if (emission > 0) { basecol *= emission; matid = 1; }
	fragColor[0] = vec4(n.xy, roughness, packFloatInt16(metallic, matid));
	fragColor[1] = vec4(basecol, packFloat2(occlusion, specular));
}
