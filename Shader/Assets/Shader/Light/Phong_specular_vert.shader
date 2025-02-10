// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone高光反射逐顶点光照
Shader "MyShader/Light/Phong_specular_vert"
{
    Properties
    {
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        _SpecularGloss("_SpecularGloss",Range(0,10)) = 0.5
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

            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               fixed3 color:COLOR;
               fixed4 pos:POSITION;
            };

            v2f vert (appdata_base dataBase)
            {
               v2f data;              
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               fixed3 worldPos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               //标准后观察方向向量
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - worldPos);
               //世界空间下光的反射向量
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //世界空间法线向量
               fixed3 worldNormal = UnityObjectToWorldNormal(dataBase.normal);
               //标准后的反射方向
               fixed3 dirEflect = normalize(reflect(-dirLight ,worldNormal));
               //高光反射光照颜色 = 光源的颜色 * 材质高光反射颜色 * max (0，标准化后观察方向向量 · 标准化后的反射方向) 幂
               data.color = _SpecularColor * _LightColor0 * ( pow( max( 0, dot( dirEflect,dirCamera)), _SpecularGloss));
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
