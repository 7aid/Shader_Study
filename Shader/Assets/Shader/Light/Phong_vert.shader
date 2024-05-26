// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phoneʽ�𶥵����
Shader "MyShader/Phong_vert"
{
    Properties
    {
        //������������ɫ
        _MainColor("_MainColor", Color) = (1,1,1,1)
        //�߹ⷴ����ɫ
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //�����
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
            //��ȡ��������������ɫ
            fixed3 getLambertColor(appdata_base dataBase)
            {
                fixed3 color;
                fixed3 wNormal = UnityObjectToWorldNormal(dataBase.normal);
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0 * _MainColor.rgb * max(0, dot(wNormal, dirLight));
                return color;
            }
            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getPhoneSpecularColor(appdata_base dataBase)
            {           
               fixed3 color;
               fixed3 worldNormal = UnityObjectToWorldNormal(dataBase.normal);
               fixed3 worldPos = mul(unity_ObjectToWorld, dataBase.vertex).xyz;
               //��׼��۲췽������
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - worldPos);
               //����ռ��¹�ĵ�λ����
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //��׼��ķ��䷽��
               fixed3 dirEflect = normalize(reflect(-dirLight ,worldNormal));
               //�߹ⷴ�������ɫ = ��Դ����ɫ * ���ʸ߹ⷴ����ɫ * max (0����׼����۲췽������ �� ��׼����ķ��䷽��) ��
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
