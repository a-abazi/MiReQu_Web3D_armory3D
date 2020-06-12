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
    float3 basecol = float3(0.80000007152557373046875f, 0.09744016826152801513671875f, 0.00292950379662215709686279296875f);
    float roughness = 0.59420287609100341796875f;
    float metallic = 1.0f;
    float occlusion = 1.0f;
    float specular = 1.0f;
    fragColor = float4(basecol, 1.0f);
    float3 _38 = pow(fragColor.xyz, 0.4545454680919647216796875f.xxx);
    fragColor = float4(_38.x, _38.y, _38.z, fragColor.w);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
