static float3 wnormal;
static float4 fragColor[2];

struct SPIRV_Cross_Input
{
    float3 wnormal : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[2] : SV_Target0;
};

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

float packFloatInt16(float f, uint i)
{
    return (0.06248569488525390625f * f) + (0.06250095367431640625f * float(i));
}

float packFloat2(float f1, float f2)
{
    return floor(f1 * 255.0f) + min(f2, 0.9900000095367431640625f);
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 basecol = float3(0.0207093656063079833984375f, 0.02127058245241641998291015625f, 0.02364858798682689666748046875f);
    float roughness = 0.4107443392276763916015625f;
    float metallic = 0.0f;
    float occlusion = 1.0f;
    float specular = 0.67973864078521728515625f;
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _97;
    if (n.z >= 0.0f)
    {
        _97 = n.xy;
    }
    else
    {
        _97 = octahedronWrap(n.xy);
    }
    n = float3(_97.x, _97.y, n.z);
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, 0u));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
