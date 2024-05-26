// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Blinn_Phone式逐顶点高光反射光照
Shader "MyShader/Blinn_Phong_specular_vert"
{
    Properties
    {
        //高光反射颜色
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularGloss("_SpecularGloss",Range(0, 10)) = 0.5
    }
    SubShader
    {    
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //光照颜色
               fixed3 color:COLOR;
               //裁剪空间顶点
               fixed4 pos:SV_POSITION;
            };
          
          
            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               fixed3 wpos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               fixed3 dirNormal = UnityObjectToWorldNormal(dataBase.normal);
               //半角向量
               fixed3 dirHalf = normalize(_WorldSpaceCameraPos - wpos) + normalize(_WorldSpaceLightPos0);
               //半角向量的方向向量
               fixed3 dirHalfNormalize = normalize(dirHalf);
               data.color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(dirHalfNormalize, dirNormal)), _SpecularGloss);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 color = i.color;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
