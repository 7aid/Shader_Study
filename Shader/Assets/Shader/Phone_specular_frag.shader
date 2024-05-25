// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone高光反射逐片元光照
Shader "MyShader/Phone_specular_frag"
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
               //裁剪空间下顶点
               fixed4 pos:SV_POSITION;
               //世界空间下法线
               fixed3 normal:NORMAL;
               //世界空间下顶点
               fixed3 worldPos:TEXCOORD;
            };

            v2f vert (appdata_base dataBase)
            {
               v2f data;              
               data.normal = UnityObjectToWorldNormal(dataBase.normal);
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.worldPos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               //标准后观察方向向量
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
               //世界空间下光的反射向量
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //标准后的反射方向
               fixed3 dirEflect = normalize(reflect(-dirLight ,i.normal));
               //高光反射光照颜色 = 光源的颜色 * 材质高光反射颜色 * max (0，标准化后观察方向向量 · 标准化后的反射方向) 幂
               fixed3 color = _SpecularColor.rgb * _LightColor0.rgb * pow( max( 0, dot( dirEflect,dirCamera)), _SpecularGloss);
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
