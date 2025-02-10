// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone式逐顶点光照
Shader "MyShader/Light/Phong_frag"
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
               //世界空间下法线
               fixed3 normal:NORMAL;
               //世界空间下顶点
               fixed3 wpos:TEXCOORD0;
               //裁剪空间下顶点
               fixed4 pos:SV_POSITION;
            };
            //获取兰伯特漫反射颜色
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0 * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //获取Phone高光反射颜色
            fixed3 getPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color;
               //标准后世界空间观察方向向量
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - wpos);
               //世界空间下光的单位向量
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //标准后的反射方向
               fixed3 dirEflect = reflect(-dirLight ,wnormal);
               //高光反射光照颜色 = 光源的颜色 * 材质高光反射颜色 * max (0，标准化后观察方向向量 · 标准化后的反射方向) 幂
               color = _LightColor0 * _SpecularColor.rgb * ( pow( max( 0, dot( dirEflect, dirCamera)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;  
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               data.normal = UnityObjectToWorldNormal(dataBase.normal);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT + getLambertColor(i.normal) + getPhoneSpecularColor(i.normal, i.wpos);
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
