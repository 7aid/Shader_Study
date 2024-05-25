// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phone�߹ⷴ����ƬԪ����
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
               //�ü��ռ��¶���
               fixed4 pos:SV_POSITION;
               //����ռ��·���
               fixed3 normal:NORMAL;
               //����ռ��¶���
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
               //��׼��۲췽������
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
               //����ռ��¹�ķ�������
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //��׼��ķ��䷽��
               fixed3 dirEflect = normalize(reflect(-dirLight ,i.normal));
               //�߹ⷴ�������ɫ = ��Դ����ɫ * ���ʸ߹ⷴ����ɫ * max (0����׼����۲췽������ �� ��׼����ķ��䷽��) ��
               fixed3 color = _SpecularColor.rgb * _LightColor0.rgb * pow( max( 0, dot( dirEflect,dirCamera)), _SpecularGloss);
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
