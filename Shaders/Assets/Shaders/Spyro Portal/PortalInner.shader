Shader "DP/Spyro/PortalInner"
{
    Properties
    {
        _DistortTex("Distortion Texture", 2D) = "white" {}
        _DistortSpeed("Distortion Scroll Speed", float) = 2
        _DistortAmount("Distortion Amount", float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.5

        struct Input
        {
            float4 vertex;

            float4 grabUV;
            float4 distortUV;
        };

        sampler2D _GrabTexture;
        sampler2D _DistortTex;
        float4 _DistortTex_ST;

        float _DistortSpeed;
        float _DistortAmount;

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.grabUV = ComputeGrabScreenPos(o.vertex);

            o.distortUV.xy = TRANSFORM_TEX(v.texcoord, _DistortTex);
            o.distortUV.zw = o.distortUV.xy;

            o.distortUV.y += _DistortSpeed * _Time.x;
            o.distortUV.z += _DistortSpeed * _Time.x;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // We need to do the texture lookup twice, as the textures move at different speed
            //  so the textures need ot use correct UVs.
            float2 distortTexture = UnpackNormal(tex2D(_DistortTex, IN.distortUV.xy)).xy;
            distortTexture *= _DistortAmount / 100;
            float2 distortTexture2 = UnpackNormal(tex2D(_DistortTex, IN.distortUV.zw)).xy;
            distortTexture2 *= _DistortAmount / 100;
            float combinedDistortion = distortTexture + distortTexture2;
            
            float4 grabPassUV = IN.grabUV;
            grabPassUV.xy += combinedDistortion * IN.grabUV;

            float4 grabPassTexture = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(grabPassUV));

            o.Albedo = grabPassTexture;
        }
        ENDCG
    }
    FallBack "Diffuse"
}