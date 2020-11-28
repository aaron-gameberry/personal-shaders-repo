Shader "DP/Stencil Cube/StencilMask"
{
    Properties
    {
        _StencilMaskRef("Stencil Mask ID", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-100" }
        ColorMask 0
        ZWrite Off

        // Stencil shader function.
        Stencil
        {
            // Reference used when comparing stencil calculations.
            // Always perform the stencil check.
            // If passed, replace what is in the buffer.
            Ref[_StencilMaskRef]
            Comp Always
            Pass Replace
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return half4(1, 1, 0, 1);
            }
            ENDCG
        }
    }
}
