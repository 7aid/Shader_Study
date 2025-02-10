//滚动背景
Shader "MyShader/DynamicEffect/ScrollingBackground"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}

        _ScrollSpeedU("ScrollSpeedU", float) = 0.5
        
        _ScrollSpeedV("ScrollSpeedV", float) = 0.5

    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _ScrollSpeedU;
            float _ScrollSpeedV;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base o)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(o.vertex);
                data.uv = o.texcoord;
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float2 uv = frac(i.uv + float2(_Time.y * _ScrollSpeedU, _Time.y * _ScrollSpeedV));
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
