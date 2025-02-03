Shader "MyShader/ModelOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //边缘线颜色
        _OutlineColor("OutlineColor", Color) = (1,1,1,1)
        //边缘线粗细
        _OutlineWidth("OutlineWidth", float) = 0.01
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue"="Transparent"}

        Pass
        {
            //关闭深度写入 目的是 第二个Pass能够覆盖重合的地方
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vert (appdata_base v)
            {
                v2f o;
                ////偏移顶点位置 朝法线方向偏移
                //让我们的顶点朝法线方向 偏移 自定义个单位 这个自定义变量 就是决定模型膨胀多少的 就可以决定边缘线的粗细
                float3 newVertex = v.vertex + normalize(v.normal) * _OutlineWidth;
                //把膨胀过后的顶点转到裁剪空间
                o.vertex = UnityObjectToClipPos(float4(newVertex.xyz, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
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

    Fallback "Diffuse"
}
