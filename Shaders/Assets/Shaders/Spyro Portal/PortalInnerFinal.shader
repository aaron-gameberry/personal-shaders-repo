Shader "DP/Spyro/PortalInnerFinal"
{
    Properties
    {
        [Header(Distortion)]
        _DistortTex("Distortion Texture", 2D) = "white" {}
        _DistortAmount("Distortion Amount", float) = 1
        _DistortScrollSpeed("Distortion Speed", float) = -1

        [Header(Edge)]
        [HDR]_EdgeColor("Edge Colour", Color) = (1,1,1,1)
        _DepthFactor("Edge Depth", float) = 1.0
        _EdgeStrength("Edge Strength", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf NoLight noshadow vertex:vert
        #pragma target 3.5

        fixed4 LightingNoLight(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo;
            c.a = s.Alpha;
            return c;
        }

        struct Input
        {
            float4 vertex;

            float2 uv_DistortTex;
            float2 distortUV;
            float2 distortUV2;
            
            float3 worldPos;
            float4 screenPos;
            
            float depth;
            
            float4 grabUV;
        };

        sampler2D _CameraDepthTexture;
        sampler2D _GrabTexture;

        sampler2D _DistortTex;
        float4 _DistortTex_ST;
        float _DistortAmount;
        float _DistortScrollSpeed;

        float4 _EdgeColor;
        float _EdgeStrength;
        float _DepthFactor;


        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.screenPos = ComputeScreenPos(o.vertex);

            o.screenPos.y = 1 - o.screenPos.y;

            o.depth = -UnityObjectToViewPos(v.vertex).z * 1.0;

            o.distortUV = TRANSFORM_TEX(v.texcoord, _DistortTex);
            o.distortUV.y += _DistortScrollSpeed * _Time.x;

            o.distortUV2 = TRANSFORM_TEX(v.texcoord, _DistortTex);
            o.distortUV2.x += _DistortScrollSpeed * _Time.x;

            o.grabUV = ComputeGrabScreenPos(o.vertex);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            float2 distort = UnpackNormal(tex2D(_DistortTex, IN.distortUV)).xy;
            distort *= _DistortAmount / 100;

            float2 distort2 = UnpackNormal(tex2D(_DistortTex, IN.distortUV2)).xy;
            distort2 *= _DistortAmount / 100;

            distort += distort2;

            float sceneZ = LinearEyeDepth(
                SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)));
            float surfZ = -mul(UNITY_MATRIX_V, float4(IN.worldPos.xyz, 1)).z;
            float diff = sceneZ - surfZ;
            float intersect = 0;

            if (diff > 0)
                intersect = 1 - saturate(diff / _DepthFactor);

            float4 interCol = intersect * _EdgeStrength * _EdgeColor;

            float2 coords = IN.screenPos.xy / IN.screenPos.w;

            IN.grabUV.xy += distort * IN.grabUV;

            float4 distortUVTing = IN.screenPos;
            distortUVTing.xy += distort * IN.screenPos;

            fixed4 grabPassSample = tex2Dproj (_GrabTexture, distortUVTing);
            
            fixed4 col = fixed4(lerp(grabPassSample, interCol, pow(intersect, 4)));

            o.Albedo = col;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
