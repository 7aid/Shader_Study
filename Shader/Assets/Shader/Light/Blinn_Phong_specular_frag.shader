// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Blinn_Phoneʽ��ƬԪ�߹ⷴ�����
Shader "MyShader/Blinn_Phong_specular_frag"
{
    Properties
    {
        //�߹ⷴ����ɫ
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //�����
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
               //����ռ䷨��
               fixed3 normal:NORMAL;
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
               //����ռ䶥��
               fixed3 wpos:TEXCOORD;
            };
          
          
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
               fixed3 dirHalf = normalize(_WorldSpaceCameraPos - i.wpos) + normalize(_WorldSpaceLightPos0);
               fixed3 dirHalfNormalize = normalize(dirHalf);
               fixed3 color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(dirHalfNormalize, i.normal)), _SpecularGloss);
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
