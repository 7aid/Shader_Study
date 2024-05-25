// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone�߹ⷴ���𶥵����
Shader "MyShader/Phone_specular_vert"
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
               //��׼��۲췽������
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - worldPos);
               //����ռ��¹�ķ�������
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //����ռ䷨������
               fixed3 worldNormal = UnityObjectToWorldNormal(dataBase.normal);
               //��׼��ķ��䷽��
               fixed3 dirEflect = normalize(reflect(-dirLight ,worldNormal));
               //�߹ⷴ�������ɫ = ��Դ����ɫ * ���ʸ߹ⷴ����ɫ * max (0����׼����۲췽������ �� ��׼����ķ��䷽��) ��
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
