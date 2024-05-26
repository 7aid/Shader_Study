// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Blinn_Phone式逐片元光照
Shader "MyShader/Blinn_Phong_frag"
{
    Properties
    {
        //材质漫反射颜色
        _MainColor("_MainColor", Color) = (1,1,1,1)
        //高光反射颜色
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularGloss("_SpecularGloss",Range(0, 10)) = 0.5
    }
    SubShader
    {
        Tags{"LightMode" = "ForwardBase"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //世界空间法线
               fixed3 wnormal:NORMAL;
               //裁剪空间顶点
               fixed4 pos:SV_POSITION;
               //世界空间顶点
               fixed3 wpos:TEXCOORD;
            };
            //获取兰伯特漫反射颜色
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;     
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //获取Phone高光反射颜色
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //对角向量
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - wpos);
               //标准化对角向量
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
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
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT + getLambertColor(i.wnormal) + getBlinnPhoneSpecularColor(i.wnormal, i.wpos);
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
