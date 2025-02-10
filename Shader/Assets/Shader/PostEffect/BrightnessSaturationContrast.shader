//屏幕颜色亮度，饱和度，对比度
Shader "MyShader/PostEffect/BrightnessSaturationContrast"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //亮度
        _Brightness("Brightness", float) = 1
        //饱和度
        _Saturation("Saturation", float) = 1
        //对比度
        _Contrast("Contrast", float) = 1
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}

        Pass
        {           
            //开启深度测试
            ZTest Always
            //关闭剔除
            Cull Off
            //关闭深度写入
            ZWrite Off
            //因为屏幕后处理效果相当于在场景上绘制了一个与屏幕同宽高的四边形面片
            //这样做的目的是避免它"挡住"后面的渲染物体
            //比如我们在OnRenderImage前加入[ImageEffectOpaque]特性时
            //透明物体会晚于该该屏幕后处理效果渲染，如果不关闭深度写入会影响后面的透明相关Pass

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Saturation;
            float _Contrast;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return data;
            }

            float4 frag(v2f i):SV_TARGET 
            {
                fixed3 renderTexcolor = tex2D(_MainTex, i.uv).rgb;
                //亮度
                fixed3 finalColor = renderTexcolor * _Brightness;
                //饱和度 
                fixed L = finalColor.r * 0.2126 + finalColor.g * 0.7152 + finalColor.b * 0.0722;
                fixed3 LColor = fixed3(L, L, L);
                finalColor = lerp(LColor, finalColor, _Saturation);
                //对比度计算
                fixed3 avgColor = float3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);
                return fixed4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
