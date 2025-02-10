//深度纹理
Shader "MyShader/PostEffect/DepthTexture"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {           

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
             //按规则命名的 深度纹理变量
            sampler2D _CameraDepthTexture;

            struct v2f
            {
                float4 vertex:SV_POSITION;    
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
               v2f o;
               o.vertex = UnityObjectToClipPos(v.vertex);
               o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
               return o;
            }
        

            float4 frag(v2f i):SV_TARGET 
            {
                //非线性的 裁剪空间下的深度值
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                //得到一个线性的 0-1区间的深度值
                fixed linearDepth = Linear01Depth(depth);
                //把深度值作为RGB颜色输入 越接近摄像 就呈现出黑色 越远离摄像机 就呈现出白色 中间就是灰色 具体就会呈现出深浅灰
                return fixed4(linearDepth, linearDepth, linearDepth, 1);
            }
            ENDCG
        }
    }

    Fallback Off
}
