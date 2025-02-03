//深度法线纹理
Shader "MyShader/DepthNormalsTexture"
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
             //按规则命名的 获取深度+法线纹理
            sampler2D _CameraDepthNormalsTexture;

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
                //直接采样 获取到的是裁剪空间下的法线和深度信息
                float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
                fixed depth;
                fixed3 normals;
                DecodeDepthNormal(depthNormal, depth, normals);
                //把深度值作为RGB颜色输入 越接近摄像 就呈现出黑色 越远离摄像机 就呈现出白色 中间就是灰色 具体就会呈现出深浅灰
                return fixed4(normals * 0.5 + 0.5, 1);
            }
            ENDCG
        }
    }

    Fallback Off
}
