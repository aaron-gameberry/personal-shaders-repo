Shader "DP/Spyro/PortalInner"
{
    Properties { }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        struct Input
        {
            // Input needs something, otherwise it will throw errors.
            float4 vertex;

            float4 screenPos;
        };

        sampler2D _GrabTexture;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.vertex = UnityObjectToClipPos(v.vertex);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 grabPassTexture = tex2Dproj(_GrabTexture, IN.screenPos);

            o.Albedo = grabPassTexture;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
