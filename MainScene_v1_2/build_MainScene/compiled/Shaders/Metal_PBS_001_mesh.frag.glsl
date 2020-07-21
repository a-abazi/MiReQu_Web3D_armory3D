#version 450
#include "compiled.inc"
#include "std/math.glsl"
#include "std/brdf.glsl"
#include "std/light_mobile.glsl"
#include "std/clusters.glsl"
#include "std/shirr.glsl"
in vec3 wnormal;
in vec4 lightPosition;
in vec4 wvpposition;
in vec3 eyeDir;
in vec3 wposition;
out vec4 fragColor;
uniform vec3 sunCol;
uniform vec3 sunDir;
uniform sampler2DShadow shadowMap;
uniform float shadowsBias;
uniform vec2 cameraProj;
uniform vec2 cameraPlane;
uniform vec4 lightsArray[maxLights * 2];
uniform sampler2D clustersData;
uniform vec4 lightsArraySpot[maxLights];
uniform vec4 shirr[7];
uniform float envmapStrength;
void main() {
vec3 n = normalize(wnormal);
vec3 vVec = normalize(eyeDir);
float dotNV = max(dot(n, vVec), 0.0);
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	float emission;
	basecol = vec3(1.0, 1.0, 1.0);
	roughness = 0.07557666301727295;
	metallic = 1.0;
	occlusion = 1.0;
	specular = 1.0;
	emission = 0.0;
	vec3 direct = vec3(0.0);
	float svisibility = 1.0;
	float sdotNL = max(dot(n, sunDir), 0.0);
	if (lightPosition.w > 0.0) {
	    vec3 lPos = lightPosition.xyz / lightPosition.w;
	    svisibility = texture(shadowMap, vec3(lPos.xy, lPos.z - shadowsBias)).r;
	}
	direct += basecol * sdotNL * sunCol * svisibility;
	vec3 albedo = basecol;
	vec3 f0 = surfaceF0(basecol, metallic);
	float viewz = linearize(gl_FragCoord.z, cameraProj);
	int clusterI = getClusterI((wvpposition.xy / wvpposition.w) * 0.5 + 0.5, viewz, cameraPlane);
	int numLights = int(texelFetch(clustersData, ivec2(clusterI, 0), 0).r * 255);
	#ifdef HLSL
	viewz += texture(clustersData, vec2(0.0)).r * 1e-9;
	#endif
	int numSpots = int(texelFetch(clustersData, ivec2(clusterI, 1 + maxLightsCluster), 0).r * 255);
	int numPoints = numLights - numSpots;
	for (int i = 0; i < min(numLights, maxLightsCluster); i++) {
	int li = int(texelFetch(clustersData, ivec2(clusterI, i + 1), 0).r * 255);
	direct += sampleLight(
	    wposition,
	    n,
	    vVec,
	    dotNV,
	    lightsArray[li * 2].xyz,
	    lightsArray[li * 2 + 1].xyz,
	    albedo,
	    roughness,
	    specular,
	    f0
	    , li, lightsArray[li * 2].w
	    , li > numPoints - 1
	    , lightsArray[li * 2 + 1].w
	    , lightsArraySpot[li].w
	    , lightsArraySpot[li].xyz
	);
	}
	fragColor = vec4(direct + basecol * shIrradiance(n, shirr) * envmapStrength, 1.0);
	fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / 2.2));
}
