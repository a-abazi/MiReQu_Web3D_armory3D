uniform float4 casData[20];
uniform float4x4 LWVPSpot0;
Texture2D<float4> shadowMapSpot[1] : register(t0);
SamplerComparisonState _shadowMapSpot_sampler[1] : register(s0);
Texture2D<float4> gbuffer0 : register(t1);
SamplerState _gbuffer0_sampler : register(s1);
Texture2D<float4> gbuffer1 : register(t2);
SamplerState _gbuffer1_sampler : register(s2);
Texture2D<float4> gbufferD : register(t3);
SamplerState _gbufferD_sampler : register(s3);
uniform float3 eye;
uniform float3 eyeLook;
uniform float2 cameraProj;
uniform float4 shirr[7];
uniform float3 backgroundCol;
uniform float envmapStrength;
Texture2D<float4> ssaotex : register(t4);
SamplerState _ssaotex_sampler : register(s4);
uniform float3 sunDir;
Texture2D<float4> shadowMap : register(t5);
SamplerComparisonState _shadowMap_sampler : register(s5);
uniform float shadowsBias;
uniform float3 sunCol;
uniform float3 pointPos;
uniform float3 pointCol;
uniform float pointBias;
uniform float2 spotData;
uniform float3 spotDir;

static float2 texCoord;
static float3 viewRay;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 viewRay : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

void unpackFloatInt16(float val, out float f, inout uint i)
{
    i = uint(int((val / 0.06250095367431640625f) + 1.525902189314365386962890625e-05f));
    f = clamp((((-0.06250095367431640625f) * float(i)) + val) / 0.06248569488525390625f, 0.0f, 1.0f);
}

float2 unpackFloat2(float f)
{
    return float2(floor(f) / 255.0f, frac(f));
}

float3 surfaceAlbedo(float3 baseColor, float metalness)
{
    return lerp(baseColor, 0.0f.xxx, metalness.xxx);
}

float3 surfaceF0(float3 baseColor, float metalness)
{
    return lerp(0.039999999105930328369140625f.xxx, baseColor, metalness.xxx);
}

float3 getPos(float3 eye_1, float3 eyeLook_1, float3 viewRay_1, float depth, float2 cameraProj_1)
{
    float linearDepth = cameraProj_1.y / (((depth * 0.5f) + 0.5f) - cameraProj_1.x);
    float viewZDist = dot(eyeLook_1, viewRay_1);
    float3 wposition = eye_1 + (viewRay_1 * (linearDepth / viewZDist));
    return wposition;
}

float3 shIrradiance(float3 nor, float4 shirr_1[7])
{
    float3 cl00 = float3(shirr_1[0].x, shirr_1[0].y, shirr_1[0].z);
    float3 cl1m1 = float3(shirr_1[0].w, shirr_1[1].x, shirr_1[1].y);
    float3 cl10 = float3(shirr_1[1].z, shirr_1[1].w, shirr_1[2].x);
    float3 cl11 = float3(shirr_1[2].y, shirr_1[2].z, shirr_1[2].w);
    float3 cl2m2 = float3(shirr_1[3].x, shirr_1[3].y, shirr_1[3].z);
    float3 cl2m1 = float3(shirr_1[3].w, shirr_1[4].x, shirr_1[4].y);
    float3 cl20 = float3(shirr_1[4].z, shirr_1[4].w, shirr_1[5].x);
    float3 cl21 = float3(shirr_1[5].y, shirr_1[5].z, shirr_1[5].w);
    float3 cl22 = float3(shirr_1[6].x, shirr_1[6].y, shirr_1[6].z);
    return ((((((((((cl22 * 0.429042994976043701171875f) * ((nor.y * nor.y) - ((-nor.z) * (-nor.z)))) + (((cl20 * 0.743125021457672119140625f) * nor.x) * nor.x)) + (cl00 * 0.88622701168060302734375f)) - (cl20 * 0.2477079927921295166015625f)) + (((cl2m2 * 0.85808598995208740234375f) * nor.y) * (-nor.z))) + (((cl21 * 0.85808598995208740234375f) * nor.y) * nor.x)) + (((cl2m1 * 0.85808598995208740234375f) * (-nor.z)) * nor.x)) + ((cl11 * 1.02332794666290283203125f) * nor.y)) + ((cl1m1 * 1.02332794666290283203125f) * (-nor.z))) + ((cl10 * 1.02332794666290283203125f) * nor.x);
}

float3 lambertDiffuseBRDF(float3 albedo, float nl)
{
    return albedo * max(0.0f, nl);
}

float d_ggx(float nh, float a)
{
    float a2 = a * a;
    float denom = pow(((nh * nh) * (a2 - 1.0f)) + 1.0f, 2.0f);
    return (a2 * 0.3183098733425140380859375f) / denom;
}

float v_smithschlick(float nl, float nv, float a)
{
    return 1.0f / (((nl * (1.0f - a)) + a) * ((nv * (1.0f - a)) + a));
}

float3 f_schlick(float3 f0, float vh)
{
    return f0 + ((1.0f.xxx - f0) * exp2((((-5.554729938507080078125f) * vh) - 6.9831600189208984375f) * vh));
}

float3 specularBRDF(float3 f0, float roughness, float nl, float nh, float nv, float vh)
{
    float a = roughness * roughness;
    return (f_schlick(f0, vh) * (d_ggx(nh, a) * clamp(v_smithschlick(nl, nv, a), 0.0f, 1.0f))) / 4.0f.xxx;
}

float4x4 getCascadeMat(float d, inout int casi, inout int casIndex)
{
    float4 comp = float4(float(d > casData[16].x), float(d > casData[16].y), float(d > casData[16].z), float(d > casData[16].w));
    casi = int(min(dot(1.0f.xxxx, comp), 4.0f));
    casIndex = casi * 4;
    return float4x4(float4(casData[casIndex]), float4(casData[casIndex + 1]), float4(casData[casIndex + 2]), float4(casData[casIndex + 3]));
}

float PCF(Texture2D<float4> shadowMap_1, SamplerComparisonState _shadowMap_1_sampler, float2 uv, float compare, float2 smSize)
{
    float3 _276 = float3(uv + ((-1.0f).xx / smSize), compare);
    float result = shadowMap_1.SampleCmp(_shadowMap_1_sampler, _276.xy, _276.z);
    float3 _285 = float3(uv + (float2(-1.0f, 0.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _285.xy, _285.z);
    float3 _296 = float3(uv + (float2(-1.0f, 1.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _296.xy, _296.z);
    float3 _307 = float3(uv + (float2(0.0f, -1.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _307.xy, _307.z);
    float3 _315 = float3(uv, compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _315.xy, _315.z);
    float3 _326 = float3(uv + (float2(0.0f, 1.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _326.xy, _326.z);
    float3 _337 = float3(uv + (float2(1.0f, -1.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _337.xy, _337.z);
    float3 _348 = float3(uv + (float2(1.0f, 0.0f) / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _348.xy, _348.z);
    float3 _359 = float3(uv + (1.0f.xx / smSize), compare);
    result += shadowMap_1.SampleCmp(_shadowMap_1_sampler, _359.xy, _359.z);
    return result / 9.0f;
}

float shadowTestCascade(Texture2D<float4> shadowMap_1, SamplerComparisonState _shadowMap_1_sampler, float3 eye_1, float3 p, float shadowsBias_1)
{
    float d = distance(eye_1, p);
    int param;
    int param_1;
    float4x4 _486 = getCascadeMat(d, param, param_1);
    int casi = param;
    int casIndex = param_1;
    float4x4 LWVP = _486;
    float4 lPos = mul(float4(p, 1.0f), LWVP);
    float3 _501 = lPos.xyz / lPos.w.xxx;
    lPos = float4(_501.x, _501.y, _501.z, lPos.w);
    float visibility = 1.0f;
    if (lPos.w > 0.0f)
    {
        visibility = PCF(shadowMap_1, _shadowMap_1_sampler, lPos.xy, lPos.z - shadowsBias_1, float2(4096.0f, 1024.0f));
    }
    float nextSplit = casData[16][casi];
    float _526;
    if (casi == 0)
    {
        _526 = nextSplit;
    }
    else
    {
        _526 = nextSplit - casData[16][casi - 1];
    }
    float splitSize = _526;
    float splitDist = (nextSplit - d) / splitSize;
    if ((splitDist <= 0.1500000059604644775390625f) && (casi != 3))
    {
        int casIndex2 = casIndex + 4;
        float4x4 LWVP2 = float4x4(float4(casData[casIndex2]), float4(casData[casIndex2 + 1]), float4(casData[casIndex2 + 2]), float4(casData[casIndex2 + 3]));
        float4 lPos2 = mul(float4(p, 1.0f), LWVP2);
        float3 _604 = lPos2.xyz / lPos2.w.xxx;
        lPos2 = float4(_604.x, _604.y, _604.z, lPos2.w);
        float visibility2 = 1.0f;
        if (lPos2.w > 0.0f)
        {
            visibility2 = PCF(shadowMap_1, _shadowMap_1_sampler, lPos2.xy, lPos2.z - shadowsBias_1, float2(4096.0f, 1024.0f));
        }
        float lerpAmt = smoothstep(0.0f, 0.1500000059604644775390625f, splitDist);
        return lerp(visibility2, visibility, lerpAmt);
    }
    return visibility;
}

float attenuate(float dist)
{
    return 1.0f / (dist * dist);
}

float shadowTest(Texture2D<float4> shadowMap_1, SamplerComparisonState _shadowMap_1_sampler, float3 lPos, float shadowsBias_1)
{
    bool _370 = lPos.x < 0.0f;
    bool _376;
    if (!_370)
    {
        _376 = lPos.y < 0.0f;
    }
    else
    {
        _376 = _370;
    }
    bool _382;
    if (!_376)
    {
        _382 = lPos.x > 1.0f;
    }
    else
    {
        _382 = _376;
    }
    bool _388;
    if (!_382)
    {
        _388 = lPos.y > 1.0f;
    }
    else
    {
        _388 = _382;
    }
    if (_388)
    {
        return 1.0f;
    }
    return PCF(shadowMap_1, _shadowMap_1_sampler, lPos.xy, lPos.z - shadowsBias_1, 1024.0f.xx);
}

float3 sampleLight(float3 p, float3 n, float3 v, float dotNV, float3 lp, float3 lightCol, float3 albedo, float rough, float spec, float3 f0, int index, float bias, bool isSpot, float spotA, float spotB, float3 spotDir_1)
{
    float3 ld = lp - p;
    float3 l = normalize(ld);
    float3 h = normalize(v + l);
    float dotNH = dot(n, h);
    float dotVH = dot(v, h);
    float dotNL = dot(n, l);
    float3 direct = lambertDiffuseBRDF(albedo, dotNL) + (specularBRDF(f0, rough, dotNL, dotNH, dotNV, dotVH) * spec);
    direct *= attenuate(distance(p, lp));
    direct *= lightCol;
    if (isSpot)
    {
        float spotEffect = dot(spotDir_1, l);
        if (spotEffect < spotA)
        {
            direct *= smoothstep(spotB, spotA, spotEffect);
        }
        float4 lPos = mul(float4(p + ((n * bias) * 10.0f), 1.0f), LWVPSpot0);
        direct *= shadowTest(shadowMapSpot[0], _shadowMapSpot_sampler[0], lPos.xyz / lPos.w.xxx, bias);
        return direct;
    }
    return direct;
}

void frag_main()
{
    float4 g0 = gbuffer0.SampleLevel(_gbuffer0_sampler, texCoord, 0.0f);
    float3 n;
    n.z = (1.0f - abs(g0.x)) - abs(g0.y);
    float2 _857;
    if (n.z >= 0.0f)
    {
        _857 = g0.xy;
    }
    else
    {
        _857 = octahedronWrap(g0.xy);
    }
    n = float3(_857.x, _857.y, n.z);
    n = normalize(n);
    float roughness = g0.z;
    float param;
    uint param_1;
    unpackFloatInt16(g0.w, param, param_1);
    float metallic = param;
    uint matid = param_1;
    float4 g1 = gbuffer1.SampleLevel(_gbuffer1_sampler, texCoord, 0.0f);
    float2 occspec = unpackFloat2(g1.w);
    float3 albedo = surfaceAlbedo(g1.xyz, metallic);
    float3 f0 = surfaceF0(g1.xyz, metallic);
    float depth = (gbufferD.SampleLevel(_gbufferD_sampler, texCoord, 0.0f).x * 2.0f) - 1.0f;
    float3 p = getPos(eye, eyeLook, normalize(viewRay), depth, cameraProj);
    float3 v = normalize(eye - p);
    float dotNV = max(dot(n, v), 0.0f);
    float3 envl = shIrradiance(n, shirr);
    envl *= albedo;
    envl += (backgroundCol * surfaceF0(g1.xyz, metallic));
    envl *= (envmapStrength * occspec.x);
    fragColor = float4(envl.x, envl.y, envl.z, fragColor.w);
    float3 _972 = fragColor.xyz * ssaotex.SampleLevel(_ssaotex_sampler, texCoord, 0.0f).x;
    fragColor = float4(_972.x, _972.y, _972.z, fragColor.w);
    if (g0.w == 1.0f)
    {
        float3 _984 = fragColor.xyz + g1.xyz;
        fragColor = float4(_984.x, _984.y, _984.z, fragColor.w);
        albedo = 0.0f.xxx;
    }
    float3 sh = normalize(v + sunDir);
    float sdotNH = dot(n, sh);
    float sdotVH = dot(v, sh);
    float sdotNL = dot(n, sunDir);
    float svisibility = 1.0f;
    float3 sdirect = lambertDiffuseBRDF(albedo, sdotNL) + (specularBRDF(f0, roughness, sdotNL, sdotNH, dotNV, sdotVH) * occspec.y);
    svisibility = shadowTestCascade(shadowMap, _shadowMap_sampler, eye, p + ((n * shadowsBias) * 10.0f), shadowsBias);
    float3 _1040 = fragColor.xyz + ((sdirect * svisibility) * sunCol);
    fragColor = float4(_1040.x, _1040.y, _1040.z, fragColor.w);
    int param_2 = 0;
    float param_3 = pointBias;
    bool param_4 = true;
    float param_5 = spotData.x;
    float param_6 = spotData.y;
    float3 param_7 = spotDir;
    float3 _1075 = fragColor.xyz + sampleLight(p, n, v, dotNV, pointPos, pointCol, albedo, roughness, occspec.y, f0, param_2, param_3, param_4, param_5, param_6, param_7);
    fragColor = float4(_1075.x, _1075.y, _1075.z, fragColor.w);
    fragColor.w = 1.0f;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    texCoord = stage_input.texCoord;
    viewRay = stage_input.viewRay;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
