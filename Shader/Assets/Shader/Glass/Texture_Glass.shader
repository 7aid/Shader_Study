//��������ʵ��
Shader "MyShader/Texture_Glass"
{
    Properties
    {
        //����
        _MainTex("MainTex", 2D) = ""{}
        //����������
        _CubeMap("CubeMap", Cube) = ""{}
        //����̶�(0��ʾ��ȫ������-�൱����ȫ���䣬1��ʾ��ȫ����-�൱����ȫ͸��)
        _RefractAmount("RefractAmount", Range(0, 1)) = 1
    }
    SubShader
    {   //�޸���Ⱦ����ΪTransparent������RenderType��Ⱦ���Ͳ��޸ģ���Ϊ�������ϻ���һ����͸������
        //�Ժ�ʹ����ɫ���滻����ʱ�������ڱ�������Ⱦ
        Tags{"RenderType" = "Opaque"  "Queue" = "Transparent"}
        //ץȡ��Ļͼ��洢��Ⱦ����
        GrabPass{}
        Pass
        {
            //���ù���Ⱦ��ʽ����͸��������ǰ��Ⱦ
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //ӳ����Ļͼ��洢��Ⱦ����
            sampler2D _GrabTexture;
            samplerCUBE _CubeMap;
            float _RefractAmount;

            struct v2f
            {
                float4 pos:SV_POSITION;
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //ץȡ��Ļ����
                float4 grabPos:TEXCOORD1;
                //������
                float3 wRefl:TEXCOORD2;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                //��������ת��
                data.pos = UnityObjectToClipPos(v.vertex);
                //��Ļ����ת����ص�����
                data.grabPos = ComputeGrabScreenPos(data.pos);
                //uv���������ص�����
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
 
                //���㷴�������
                //1.��������ռ��·�������
                fixed3 wNormal = UnityObjectToWorldNormal(v.normal);
                //2.����ռ��µĶ�������
                fixed3 wPos = mul(unity_ObjectToWorld, v.vertex);
                //3.�����ӽǷ��� �ڲ����������λ�� - ��������λ�� 
                fixed3 wViewDir = UnityWorldSpaceViewDir(wPos);
                //4.���㷴������
                data.wRefl = reflect(-wViewDir, wNormal);
                return data;
            }

            fixed4 frag (v2f i):SV_Target
            {
               //�ڴ˴������uv�Ǿ�����ֵ������ ÿһ��ƬԪ�����Լ���һ��uv����
               //�����Żᾫ׼������ͼ����ȡ����ɫ
               fixed4 mainColor = tex2D(_MainTex, i.uv);
               //��������ɫ����������ɫ���е���
               fixed4 reflColor = texCUBE(_CubeMap, i.wRefl) * mainColor;

               //������ص���ɫ
               //��ʵ���Ǵ�����ץȡ�� ��Ļ��Ⱦ�����н��в��� �������
               //ץȡ�����е���ɫ��Ϣ �൱���������������������ɫ

               //��Ҫ������Ч�� �����ڲ���֮ǰ ����xy��Ļ�����ƫ��
               float2 offset = 1 - _RefractAmount;
               //xyƫ��һ��λ��
               i.grabPos.xy = i.grabPos.xy - offset / 10;

               //����͸�ӳ��� ����Ļ����ת���� 0~1��Χ�� Ȼ���ٽ��в���
               fixed2 screenUV = i.grabPos.xy / i.grabPos.w;
               //�Ӳ������Ⱦ�����н��в��� ��ȡ�������ɫ
               fixed4 grabColor = tex2D(_GrabTexture, screenUV);
               //����̶� 0~1 0������ȫ���䣨��ȫ�����䣩1������ȫ���䣨͸��Ч�� �൱�ڹ�ȫ���������ڲ���
               fixed4 color = reflColor * (1 - _RefractAmount) + grabColor * _RefractAmount;

               return color;
            }
            ENDCG
        }
    }
}
