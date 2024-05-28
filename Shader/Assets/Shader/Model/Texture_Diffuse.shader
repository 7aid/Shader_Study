//切线空间下 实现法线纹理shader
Shader "MyShader/Texture_Diffuse"
{
    Properties
    {   //材质漫反射颜色
        _MainColor("MainColor",Color) = (1,1,1,1)
        //单张纹理信息
        _MainTex ("Texture", 2D) = ""{}
        //法线纹理信息
        _BumpTex("BumpTex", 2D) = ""{}
        //凹凸程度
        _BumpNum("BumpNum", Range(0,2)) = 1
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularNum("SpecularNum", Range(0,20)) = 5
    }
    SubShader
    {
        Pass
        {   //设置光渲染方式，不透明物体使用向前渲染
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                //裁剪空间坐标
                fixed4 pos:SV_POSITION;
                //UV坐标 xy为主贴图uv坐标  zw为法线贴图uv坐标
                fixed4 uv:TEXCOORD0;
                //切线空间下光的方向
                fixed3 lightDir:TEXCOORD1;
                //切线空间下视角方向
                fixed3 viewDir:TEXCOORD2;
            };
            //材质漫反射颜色
            fixed4 _MainColor;
            //纹理
            sampler2D _MainTex;
            //纹理的缩放和偏移
            fixed4 _MainTex_ST;
            //法线纹理
            sampler2D _BumpTex;
            //法线纹理的缩放和偏移
            fixed4 _BumpTex_ST;
          

            v2f vert (appdata_full full)
            {
                data.pos = UnityObjectToClipPos(full.vertex);
                //主帖图uv坐标
                data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //法线贴图uv坐标
                data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //副切线
                fixed3 tangentMinor = cross(full.normal, full.tangent);
                //矩阵
                fixed3x3 mulM2T = (full.normal, tangentMinor, full.tangent);

            }

            fixed4 frag (v2f data) : SV_Target
            {

            }
            ENDCG
        }
    }
}
