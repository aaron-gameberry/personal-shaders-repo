Shader "DP/Spyro/PortalInner Cubemap"
{
    Properties
    {
        _Cubemap ("Cubemap Texture", CUBE) = "" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        struct Input
        {
            float3 viewDir;
        };

        samplerCUBE _Cubemap;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = texCUBE (_Cubemap, IN.viewDir);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
