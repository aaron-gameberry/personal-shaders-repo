Shader "Custom/CrackedIce"
{
    Properties
    {
        _IceTint ("Ice Texture Tint", Color) = (1,1,1,1)
        _MainTex ("Ice Albedo (RGB)", 2D) = "white" {}
        _CrackLayers("Packed Cracks Texture", 2D) = "white" {}
        _OffsetScale("Crack Offset Scale", float) = 0.5
        _CracksStrength("Cracks Fade Strength", vector) = (0.0, .75, .45, .25)
        _NormalTex ("Ice Normal Texture", 2D) = "bump" {}
        _Roughness ("Ice Roughness Texture", 2D) = "black" {}
        _RoughnessStrength ("Roughness Strength", Range(0.0, 1.0)) = 0.4
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.5

        sampler2D _MainTex;
        sampler2D _NormalTex;
        sampler2D _CrackLayers;
        sampler2D _Roughness;

        half _OffsetScale;
        half _RoughnessStrength;
        half4 _CracksStrength;

        half _Metallic;
        fixed4 _IceTint;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalTex;
            float2 uv_CrackLayers;
            float2 uv_Roughness;

            float3 viewDirTangent;
        };

        // From Unity's shader graph manual.
        float4 blendMultiply (float4 baseTex, float4 blendTex, float opacity)
        {
            float4 baseBlend = baseTex * blendTex;
            float4 ret = lerp(baseTex, baseBlend, opacity);
            return ret;
        }

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // [VIEW DIRECTION IN TANGENT SPACE] : In order for parallax to work correctly, we need to find
            //  view direction of the camera in tangent space. Calculation below takes care of that.
            // Credit: Harry Alisavakis
            float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
            float3 viewDir = v.vertex.xyz - objCam.xyz;
            float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
            float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;
            o.viewDirTangent = float3(
                dot(viewDir, v.tangent.xyz),
                dot(viewDir, bitangent.xyz),
                dot(viewDir, v.normal.xyz)
            );
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex) * _IceTint;
            fixed3 normalTex = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            fixed rougnessTex = tex2D(_Roughness, IN.uv_Roughness).r * _RoughnessStrength;

            fixed parallax = 0;
            for (int j = 0; j < 4; j ++) {
                float ratio = (float) j / 4;

                if (j == 0)
                {
                    // I don't want to show the first layer, because this would be flat on the object (no depth),
                    //   I want to start with the second iteration of the parallax effect, which will have depth.
                }
                else if (j == 1)
                {
                    // First layer of cracks.
                    parallax += tex2D(_CrackLayers, IN.uv_CrackLayers + lerp(0, _OffsetScale, ratio) * normalize(IN.viewDirTangent) + normalTex).g * _CracksStrength.y;
                }
                else if (j == 2)
                {
                    // Second layer of cracks.
                    parallax += tex2D(_CrackLayers, IN.uv_CrackLayers + lerp(0, _OffsetScale, ratio) * normalize(IN.viewDirTangent) + normalTex).b * _CracksStrength.z;
                }
                else if (j == 3)
                {
                    // Third layer of cracks.
                    parallax += tex2D(_CrackLayers, IN.uv_CrackLayers + lerp(0, _OffsetScale, ratio) * normalize(IN.viewDirTangent) + normalTex).r * _CracksStrength.w;
                }
            }
            parallax *= 1.5;

            fixed4 blended = blendMultiply(mainTex, parallax, 0.55);

            o.Albedo = blended;
            o.Normal = normalTex;
            o.Metallic = _Metallic;

            // In my example I reverse the roughness texture, because unity uses white as flat, 
            //   but I prefer to use black as flat (easier on eyes, and I can see the texture better).
            o.Smoothness = 1 - rougnessTex;
        }
        ENDCG
    }
    FallBack "Diffuse"
}