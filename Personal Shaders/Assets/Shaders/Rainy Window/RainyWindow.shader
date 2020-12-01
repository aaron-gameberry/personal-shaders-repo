Shader "DP/RainyWindow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GridSize ("Grid Size", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GridSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = 0;

                float2 aspect = float2(2, 1);
                float2 uv = i.uv * _GridSize * aspect;
                float2 gv = frac(uv) - 0.5;

                float x = 0; float y = sin(_Time.y) * .45;
                float2 dropPos = (gv - float2(x, y)) / aspect;

                float drop = smoothstep(.05, .03, length(dropPos));
                col+=drop;

                //col.rg = gv;
                if (gv.x > .48 || gv.y > .49) col = float4(1, 0, 0, 1);
                
                return col;
            }
            ENDCG
        }
    }
}
