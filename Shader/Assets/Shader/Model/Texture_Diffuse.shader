//���߿ռ��� ʵ�ַ�������shader
Shader "MyShader/Texture_Diffuse"
{
    Properties
    {   //������������ɫ
        _MainColor("MainColor",Color) = (1,1,1,1)
        //����������Ϣ
        _MainTex ("MainTex", 2D) = ""{}
        //����������Ϣ
        _BumpTex("BumpTex", 2D) = ""{}
        //��͹�̶�
        _BumpNum("BumpNum", Range(0,2)) = 1
        //�߹ⷴ����ɫ
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecularNum("SpecularNum", Range(0,20)) = 5
    }
    SubShader
    {
        Pass
        {   //���ù���Ⱦ��ʽ����͸������ʹ����ǰ��Ⱦ
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                //�ü��ռ�����
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //���ǿ��Ե�������������float2�ĳ�Ա���ڼ�¼ ��ɫ�ͷ��������uv����
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //���߿ռ��¹�ķ���
                float3 lightDir:TEXCOORD1;
                //���߿ռ����ӽǷ���
                float3 viewDir:TEXCOORD2;
            };
            //������������ɫ
            float4 _MainColor;
            //����
            sampler2D _MainTex;
            //��������ź�ƫ��
            float4 _MainTex_ST;
            //��������
            sampler2D _BumpTex;
            //������������ź�ƫ��
            float4 _BumpTex_ST;
            //��͹�̶�
            float _BumpNum;
            //�߹ⷴ����ɫ
            fixed4 _SpecularColor;
            //�߷������
            float _SpecularNum;

            v2f vert (appdata_full full)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(full.vertex);
                //����ͼuv����
                data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //������ͼuv����
                data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //������
                fixed3 tangentMinor = cross( normalize(full.tangent), normalize(full.normal)) * full.tangent.w;
                //����
                float3x3 mulM2T = float3x3(full.tangent.xyz, tangentMinor, full.normal );
                //���߿ռ���շ���
                data.lightDir = mul(mulM2T, ObjSpaceLightDir(full.vertex));
                 //���߿ռ��ӽǷ���
                data.viewDir = mul(mulM2T, ObjSpaceViewDir(full.vertex));

                return data;

            }

            fixed4 frag (v2f data) : SV_Target
            {
                fixed3 color;
                //ȡ��������ͼ�ķ�����Ϣ
                float4 packNormal = tex2D(_BumpTex, data.uv.zw);
                //���ڷ���XYZ������Χ��[-1��1]֮�������RGB������Χ��[0��1]֮��
                //normalTex = normalTex * 2 - 1;
                //Ҳ����ʹ��UnpackNormal�����Է�����Ϣ�����������Լ����ܵĽ�ѹ 
                float3 tangentNormal = UnpackNormal(packNormal);
                //����BumpScale���ڿ��ư�͹�̶�
                tangentNormal *= _BumpNum;
                //����ͼ��ɫ����������ɫ���ӵ���
                fixed3 albedo = tex2D(_MainTex, data.uv.xy) * _MainColor.rgb;
                //��ȡ�����������������ɫ
                fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, normalize(data.lightDir)));
                //��ȡ�Խ������ı�׼��
                fixed3 halfDir = normalize(normalize(data.lightDir) + normalize(data.viewDir));
                //��ȡ���ַ��߹ⷴ����ɫ
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(tangentNormal, halfDir)), _SpecularNum);
                //��ȡ���ַ�����ģ��
                color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + lambertColor + specularColorBack;
                return fixed4(color, 1);

            }
            ENDCG
        }
    }
}
