// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone式逐顶点光照
Shader "MyShader/Phong_vert"
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
               fixed3 color:COLOR;
               fixed4 pos:SV_POSITION;
            };
            //获取兰伯特漫反射颜色
            fixed3 getLambertColor(appdata_base dataBase)
            {
                fixed3 color;
                fixed3 wNormal = UnityObjectToWorldNormal(dataBase.normal);
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0 * _MainColor.rgb * max(0, dot(wNormal, dirLight));
                return color;
            }
            //获取Phone高光反射颜色
            fixed3 getPhoneSpecularColor(appdata_base dataBase)
            {           
               fixed3 color;
               fixed3 worldNormal = UnityObjectToWorldNormal(dataBase.normal);
               fixed3 worldPos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               //标准后观察方向向量
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - worldPos);
               //世界空间下光的单位向量
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //标准后的反射方向
               fixed3 dirEflect = normalize(reflect(-dirLight ,worldNormal));
               //高光反射光照颜色 = 光源的颜色 * 材质高光反射颜色 * max (0，标准化后观察方向向量 · 标准化后的反射方向) 幂
               color = _LightColor0 * _SpecularColor.rgb * ( pow( max( 0, dot( dirEflect, dirCamera)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;  
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.color = UNITY_LIGHTMODEL_AMBIENT + getLambertColor(dataBase) + getPhoneSpecularColor(dataBase);
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
