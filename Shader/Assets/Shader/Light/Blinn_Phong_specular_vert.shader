// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Blinn_Phoneʽ�𶥵�߹ⷴ�����
Shader "MyShader/Blinn_Phong_specular_vert"
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
               //������ɫ
               fixed3 color:COLOR;
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
            };
          
          
            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               fixed3 wpos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               fixed3 dirNormal = UnityObjectToWorldNormal(dataBase.normal);
               //�������
               fixed3 dirHalf = normalize(_WorldSpaceCameraPos - wpos) + normalize(_WorldSpaceLightPos0);
               //��������ķ�������
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
