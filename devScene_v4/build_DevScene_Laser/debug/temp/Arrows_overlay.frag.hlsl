static float3 wnormal;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float3 wnormal : TEXCOORD0;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 basecol = float3(1.0f, 0.22303746640682220458984375f, 0.009950183331966400146484375f);
    float roughness = 0.208728015422821044921875f;
    float metallic = 1.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    fragColor = float4(basecol, 1.0f);
    float3 _37 = pow(fragColor.xyz, 0.4545454680919647216796875f.xxx);
    fragColor = float4(_37.x, _37.y, _37.z, fragColor.w);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
