// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Phoneʽ�𶥵����
Shader "MyShader/Phong_frag"
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
               //����ռ��·���
               fixed3 normal:NORMAL;
               //����ռ��¶���
               fixed3 wpos:TEXCOORD0;
               //�ü��ռ��¶���
               fixed4 pos:SV_POSITION;
            };
            //��ȡ��������������ɫ
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0 * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color;
               //��׼������ռ�۲췽������
               fixed3 dirCamera = normalize(_WorldSpaceCameraPos.xyz - wpos);
               //����ռ��¹�ĵ�λ����
               fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
               //��׼��ķ��䷽��
               fixed3 dirEflect = reflect(-dirLight ,wnormal);
               //�߹ⷴ�������ɫ = ��Դ����ɫ * ���ʸ߹ⷴ����ɫ * max (0����׼����۲췽������ �� ��׼����ķ��䷽��) ��
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
