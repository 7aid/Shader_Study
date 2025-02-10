Shader "MyShader/Practice/OcclusionTransparent2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //菲涅尔反射 垂直角度反射率
        _FresnelScale("FresnelScale", Range(0,2)) = 1
         //菲涅尔反射近似公式中的 N次方
        _FresnelN("FresnelN", Range(0,5)) = 5
        //颜色
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            //深度测试改为大于
            ZTest Greater
            //关闭深度写入
            ZWrite Off
            //传统透明混合因子
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 wViewDir:TEXCOORD0;
                float3 wNormal:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelScale;
            float _FresnelN;
            float4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.wViewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //菲涅尔反射公式  R(θ) = R0 + (1− R0 )(1 − V·𝑵)^𝟓 
               float alpha = _FresnelScale + (1 - _FresnelScale) * pow((1 - dot(i.wViewDir, normalize(i.wNormal))), _FresnelN); 
               return fixed4(_Color.rgb, alpha);
            }
            ENDCG
        }

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
