#version 450
#include "compiled.inc"
#include "std/light.glsl"
#include "std/shirr.glsl"
in vec3 wnormal;
in vec3 eyeDir;
out vec4 fragColor[2];
uniform vec4 shirr[7];
uniform vec3 backgroundCol;
uniform float envmapStrength;
uniform bool receiveShadow;
uniform vec3 sunCol;
uniform vec3 sunDir;
void main() {
vec3 n = normalize(wnormal);

    vec3 vVec = normalize(eyeDir);
    float dotNV = max(dot(n, vVec), 0.0);

	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float opacity;
	basecol = vec3(0.8);
	roughness = 0.28947365283966064;
	metallic = 0.0;
	occlusion = 1.0;
	specular = 1.0;
	opacity = (1.0 - vec3(0.33442023396492004, 0.2874012887477875, 0.328825443983078).r) - 0.0002;
	if (opacity == 1.0) discard;
	vec3 albedo = surfaceAlbedo(basecol, metallic);
	vec3 f0 = surfaceF0(basecol, metallic);
	vec3 indirect = shIrradiance(n, shirr);
	indirect *= albedo;
	indirect += backgroundCol * f0;
	indirect *= occlusion;
	indirect *= envmapStrength;
	vec3 direct = vec3(0.0);
	float svisibility = 1.0;
	vec3 sh = normalize(vVec + sunDir);
	float sdotNL = dot(n, sunDir);
	float sdotNH = dot(n, sh);
	float sdotVH = dot(vVec, sh);
	direct += (lambertDiffuseBRDF(albedo, sdotNL) + specularBRDF(f0, roughness, sdotNL, sdotNH, dotNV, sdotVH) * specular) * sunCol * svisibility;	

	vec4 premultipliedReflect = vec4(vec3(direct + indirect * 0.5) * opacity, opacity);
	float w = clamp(pow(min(1.0, premultipliedReflect.a * 10.0) + 0.01, 3.0) * 1e8 * pow(1.0 - (gl_FragCoord.z) * 0.9, 3.0), 1e-2, 3e3);
	fragColor[0] = vec4(premultipliedReflect.rgb * w, premultipliedReflect.a);
	fragColor[1] = vec4(premultipliedReflect.a * w, 0.0, 0.0, 1.0);
}
