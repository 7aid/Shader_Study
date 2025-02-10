//布林方光照和渐变纹理Shader
Shader "MyShader/Model/Texture_Gradual"
{
   Properties
    {
        //材质漫反射颜色
        _MainColor("MainColor", Color) = (1,1,1,1)
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularGloss("SpecularGloss",Range(8, 255)) = 10
        //渐变纹理
        _GradualTex("GradualTex", 2D) = ""{}

    }
    SubShader
    {
        Pass
        {
            //设置光源渲染模式
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //主材质颜色
            fixed4 _MainColor;
            //高光反射颜色
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            //渐变纹理
            sampler2D _GradualTex;
            //渐变纹理缩放偏移
            float4 _GradualTex_ST;
            struct v2f
            {
               //裁剪空间顶点
               fixed4 pos:SV_POSITION;
               //世界空间顶点
               fixed3 wpos:TEXCOORD;
               //世界空间法线
               fixed3 wnormal:TEXCOORD1;
            };

            //获取Phone高光反射颜色
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //对角向量
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(UnityWorldSpaceViewDir(wpos));
               //标准化对角向量
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot(wnormal , dirHalfNormalize)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 dirLight = normalize( _WorldSpaceLightPos0);
               //获取半兰特余弦值[0,1]用于获取渐变纹理
               float halfLambert = dot(normalize(i.wnormal), dirLight) * 0.5 + 0.5;
               //获取在渐变纹理中获取的颜色与漫反射叠加
               fixed3 diffuseColor = _LightColor0.rgb * _MainColor.rgb * tex2D(_GradualTex, fixed2(halfLambert, halfLambert));
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + diffuseColor + getBlinnPhoneSpecularColor(normalize(i.wnormal), i.wpos);
               return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }
}
