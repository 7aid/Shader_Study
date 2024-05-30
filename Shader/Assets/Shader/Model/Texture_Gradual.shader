//���ַ����պͽ�������Shader
Shader "MyShader/Texture_Gradual"
{
   Properties
    {
        //������������ɫ
        _MainColor("MainColor", Color) = (1,1,1,1)
        //�߹ⷴ����ɫ
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecularGloss("SpecularGloss",Range(8, 255)) = 10
        //��������
        _GradualTex("GradualTex", 2D) = ""{}

    }
    SubShader
    {
        Pass
        {
            //���ù�Դ��Ⱦģʽ
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //��������ɫ
            fixed4 _MainColor;
            //�߹ⷴ����ɫ
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            //��������
            sampler2D _GradualTex;
            //������������ƫ��
            float4 _GradualTex_ST;
            struct v2f
            {
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
               //����ռ䶥��
               fixed3 wpos:TEXCOORD;
               //����ռ䷨��
               fixed3 wnormal:TEXCOORD1;
            };

            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //�Խ�����
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(UnityWorldSpaceViewDir(wpos));
               //��׼���Խ�����
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot(wnormal , dirHalfNormalize)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 dirLight = normalize( _WorldSpaceLightPos0);
               //��ȡ����������ֵ[0,1]���ڻ�ȡ��������
               float halfLambert = dot(normalize(i.wnormal), dirLight) * 0.5 + 0.5;
               //��ȡ�ڽ��������л�ȡ����ɫ�����������
               fixed3 diffuseColor = _LightColor0.rgb * _MainColor.rgb * tex2D(_GradualTex, fixed2(halfLambert, halfLambert));
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + diffuseColor + getBlinnPhoneSpecularColor(normalize(i.wnormal), i.wpos);
               return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }
}
