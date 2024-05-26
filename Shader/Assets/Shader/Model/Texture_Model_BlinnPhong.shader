Shader "MyShader/Texture_Model_BlinnPhong"
{
    Properties
    {
        //������ͼ
        _MainTex ("Texture", 2D) = "" {}
        //���������ɫ
        _MainColor ("MainColor", Color) = (1,1,1,1)
        //�߹ⷴ����ɫ
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecGloss ("SpecGloss", Range(0, 20)) = 0.5  
    }
    SubShader
    {
        Tags{"LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //������ͼ��ɫ
            sampler2D _MainTex;
            //������ͼ���ź�ƫ��
            float4 _MainTex_ST;
            //��������ɫ
            fixed4 _MainColor;
            //�߹ⷴ����ɫ
            fixed4 _SpecularColor;
            //�����
            fixed _SpecGloss;
            
            //��ȡ������������
            fixed3 getLambertColor(fixed3 wNormal, fixed3 albedo)
            {
                fixed3 color;
                fixed3 dirLight = normalize(_WorldSpaceLightPos0);
                color = _LightColor0.rgb * albedo * max(0, dot(wNormal, dirLight));
                return color;
            }
            //��ȡ���ָ߹ⷴ����ɫ
            fixed3 getSpecColor(fixed3 wNormal, fixed3 wPos)
            {
                fixed3 color;
                //������� = �ӽǵ�λ���� + ��Դ��λ����
                fixed3 dirHalf = normalize(_WorldSpaceCameraPos.xyz - wPos) + normalize(_WorldSpaceLightPos0);
                color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(wNormal, normalize(dirHalf))), _SpecGloss);
                return color;
            }

            struct v2f
            {
                //�ü��ռ�����
                fixed4 pos:SV_POSITION;
                //������Ϣ
                fixed2 uv:TEXCOORD0;
                //���編��
                fixed3 wNormal:NORMAL;
                //��������
                fixed3 wPos:TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.wz;
                //data.uv = TRANSFORM_UV(v.texcoord.xy, _MainTex);
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                data.wPos = mul(unity_ObjectToWorld, v.vertex);
                return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               //�ڴ˴������uv�Ǿ�����ֵ������ ÿһ��ƬԪ�����Լ���һ��uv����
               //�����Żᾫ׼������ͼ����ȡ����ɫ
               //������ɫ��Ҫ�������������ɫ���е��ӹ�ͬ�������յ���ɫ
               fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainColor.rgb;
               fixed3 lambertColor = getLambertColor(i.wNormal, albedo);
               fixed3 specColor = getSpecColor(i.wNormal, i.wPos);
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + lambertColor + specColor;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
