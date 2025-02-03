//运动模糊效果
Shader "MyShader/MotionBlur"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //模糊程度
        _BlurAmount("BlurAmount", float) = 0.5
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"
        
        sampler2D _MainTex;
        float _BlurAmount;
         
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
        };

        v2f vert(appdata_base v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        //由两张图片根据模糊程度决定最终混合效果
        Pass
        {
             //混合因子: ((源颜色 * SrcAlpha) + (目标颜色 * (1 - SrcAlpha))）
             Blend SrcAlpha OneMinusSrcAlpha
             //颜色蒙版设置：只改变颜色缓冲区中的RGB通道
             ColorMask RGB

             CGPROGRAM
             #pragma vertex vert
             #pragma fragment fragRGB

             fixed4 fragRGB(v2f i):SV_Target
             {
                 return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount); 
             }

             ENDCG
        }

        //混合A通道，由当前屏幕图像的A通道来决定
        Pass
        {
             //最终颜色 = (源颜色 * 1) + (目标颜色 * 0)）
             Blend One Zero
             //ColorMask A（只改变颜色缓冲区中的A通道）
             ColorMask A
             CGPROGRAM
             #pragma vertex vert
             #pragma fragment fragA

             fixed4 fragA(v2f i):SV_Target
             {
                 return fixed4(tex2D(_MainTex, i.uv)); 
             }
             ENDCG
        }
    }

    Fallback Off
}
