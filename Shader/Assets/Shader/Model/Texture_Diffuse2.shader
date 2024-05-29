//����ռ��� ʵ�ַ�������shader
Shader "MyShader/Texture_Diffuse2"
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
                fixed4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //���ǿ��Ե�������������float2�ĳ�Ա���ڼ�¼ ��ɫ�ͷ��������uv����
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                fixed4 uv:TEXCOORD0;
                //����ռ�����
                //fixed4 wPos:TEXCOORD1;
                //����  ���߿ռ䵽����ռ�
                //float3x3 mulT2W:TEXCOORD2;
                //Ϊ�����GPU����Ч�ʽ�float3x3�ľ����޸�Ϊfloat4�ľ��󣬲���w����wPos����
                float4 mulLine1:TEXCOORD2;
                float4 mulLine2:TEXCOORD3;
                float4 mulLine3:TEXCOORD4;

            };
            //������������ɫ
            fixed4 _MainColor;
            //����
            sampler2D _MainTex;
            //��������ź�ƫ��
            fixed4 _MainTex_ST;
            //��������
            sampler2D _BumpTex;
            //������������ź�ƫ��
            fixed4 _BumpTex_ST;
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
                //����ռ䷨��
                fixed3 wNormal = UnityObjectToWorldNormal(full.normal);
                //����ռ�����
                fixed3 wTangent = UnityObjectToWorldDir(full.tangent.xyz);
                //����ռ丱����
                fixed3 wbiTangent = cross(normalize(wTangent), normalize(wNormal)) * full.tangent.w;
                //����  ����ռ䵽���߿ռ��
                //float3x3 mulW2T = float3x3(full.tangent.xyz, biTangent, full.normal);
                fixed3 wPos = mul(unity_ObjectToWorld, full.vertex).xyz;
                //����  ���߿ռ䵽����ռ�
                //float3x3 mulT2W = float3x3
                //(
                //float3(full.tangent.x, biTangent.x, full.normal.x),
                //float3(full.tangent.y, biTangent.y, full.normal.y),
                //float3(full.tangent.z, biTangent.z, full.normal.z)
                //);
                //data.mulT2W = mulT2W;
                data.mulLine1 = float4(wTangent.x, wbiTangent.x, wNormal.x, wPos.x);
                data.mulLine2 = float4(wTangent.y, wbiTangent.y, wNormal.y, wPos.y);
                data.mulLine3 = float4(wTangent.z, wbiTangent.z, wNormal.z, wPos.z);
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
                tangentNormal.xy *= _BumpNum;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //����ռ���ͼ����
                //fixed3 wTangentNormal = mul(data.mulT2W, tangentNormal);
                float3 wTangentNormal = float3(dot(data.mulLine1.xyz, tangentNormal), dot(data.mulLine2.xyz, tangentNormal),  dot(data.mulLine3.xyz, tangentNormal));
                //����ͼ��ɫ����������ɫ���ӵ���
                fixed3 albedo = tex2D(_MainTex, data.uv.xy) * _MainColor.rgb;
                //����ռ�����
                //fixed3 wPos = data.wPos;
                fixed3 wPos = fixed3(data.mulLine1.w, data.mulLine2.w, data.mulLine3.w);
                //��׼������ռ��Դ����
                fixed3 dirLight = normalize(UnityWorldSpaceLightDir(wPos));
                //��׼������ռ��ӽǷ���
                fixed3 dirView = normalize(UnityWorldSpaceViewDir(wPos));
                //��ȡ�����������������ɫ
                fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(wTangentNormal, dirLight));
                //��ȡ�Խ������ı�׼��
                float3 halfDir = normalize(dirLight + dirView);
                //��ȡ���ַ��߹ⷴ����ɫ
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(wTangentNormal, halfDir)), _SpecularNum);
                //��ȡ���ַ�����ģ��
                color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + lambertColor + specularColorBack;
                return fixed4(color, 1);

            }
            ENDCG
        }
    }
}
