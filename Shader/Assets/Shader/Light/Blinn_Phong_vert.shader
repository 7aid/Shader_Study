// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

//Blinn_Phoneʽ�𶥵����
Shader "MyShader/Blinn_Phong_vert"
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
                //������ɫ
               fixed3 color:COLOR;
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
            };
            //��ȡ��������������ɫ
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;     
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //�Խ�����
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - wpos);
               //��׼���Խ�����
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               fixed3 wnormal = UnityObjectToWorldNormal(dataBase.normal);
               fixed3 wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.color = UNITY_LIGHTMODEL_AMBIENT + getLambertColor(wnormal) + getBlinnPhoneSpecularColor(wnormal, wpos);
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
