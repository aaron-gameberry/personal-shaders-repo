Shader "DP/Spyro/PortalInner"
{
    Properties
    {
        _DistortTex("Distortion Texture", 2D) = "white" {}
        _DistortSpeed("Distortion Scroll Speed", float) = 2
        _DistortAmount("Distortion Amount", float) = 5
        _OutlineColor("Outline Color (RGB)", Color) = (0, 1, 0, 1)
        _OutlineThresholdMax("Outline Threshold Max", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard noshadow vertex:vert
        #pragma target 3.5

        struct Input
        {
            float4 vertex;

            float4 grabUV;
            float4 distortUV;
            float4 screenPos;
            float3 worldPos;

        };

        sampler2D _GrabTexture;
        sampler2D _DistortTex;
        sampler2D _CameraDepthTexture;
        float4 _DistortTex_ST;

        float _DistortSpeed;
        float _DistortAmount;

        float4 _OutlineColor;
        float _OutlineThresholdMax;
        float _IntersectionDamper;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.grabUV = ComputeGrabScreenPos(o.vertex);

            o.distortUV.xy = TRANSFORM_TEX(v.texcoord, _DistortTex);
            o.distortUV.zw = o.distortUV.xy;

            o.distortUV.y += _DistortSpeed * _Time.x;
            o.distortUV.z += _DistortSpeed * _Time.x;

            o.screenPos = ComputeScreenPos(o.vertex);
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // CREATING THE DISTORTION EFFECT
            // We need to do the texture lookup twice, as the textures move at different speed
            //  so the textures need ot use correct UVs.
            float2 distortTexture = UnpackNormal(tex2D(_DistortTex, IN.distortUV.xy)).xy;
            distortTexture *= _DistortAmount / 100;
            float2 distortTexture2 = UnpackNormal(tex2D(_DistortTex, IN.distortUV.zw)).xy;
            distortTexture2 *= _DistortAmount / 100;
            float combinedDistortion = distortTexture + distortTexture2;
            
            float4 grabPassUV = IN.grabUV;
            grabPassUV.xy += combinedDistortion * IN.grabUV;
            
            // SAMPLING THE BACKGROUND
            fixed4 grabPassTexture = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(grabPassUV));

            // OUTLINE EFFECT
            float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)));
            float surfZ = -mul(UNITY_MATRIX_V, float4(IN.worldPos.xyz, 1)).z;
            float diff = sceneZ - surfZ;
            float intersect = 0;

            if (diff > 0)
                intersect = 1 - saturate(diff / _OutlineThresholdMax);
            
            float4 intersectColor = intersect * 4.0 * _OutlineColor;
            fixed4 finalColor = fixed4(lerp(grabPassTexture, intersectColor, pow(intersect, 4)));

            o.Albedo = finalColor.rgb;
            o.Emission = intersectColor.rgb;
        }
        ENDCG
    }
}