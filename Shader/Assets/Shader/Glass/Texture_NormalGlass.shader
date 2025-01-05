//��������ʵ�ִ�����
Shader "MyShader/Texture_NormalGlass"
{
     Properties
    {
        //����
        _MainTex("MainTex", 2D) = ""{}
         //��������
        _BumpTex("BumpTex", 2D) = ""{}
        //����������
        _CubeMap("CubeMap", Cube) = ""{}
        //����̶�(0��ʾ��ȫ������-�൱����ȫ���䣬1��ʾ��ȫ����-�൱����ȫ͸��)
        _RefractAmount("RefractAmount", Range(0, 1)) = 1   
        //��������Ť���ı���
        _Distortion("Distortion", Range(0,10)) = 0
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

            //������
            sampler2D _MainTex;
            float4 _MainTex_ST;
            //���߲���
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            //ӳ����Ļͼ��洢��Ⱦ����
            sampler2D _GrabTexture;
            //����������
            samplerCUBE _CubeMap;
            float _RefractAmount;
            //��������Ť���ı���
            float _Distortion;
            struct v2f
            {
                float4 pos:SV_POSITION;
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //ץȡ��Ļ����
                float4 grabPos:TEXCOORD1;
                //���߿ռ䵽����ռ�ľ���
                float4 mulLine1:TEXCOORD2;
                float4 mulLine2:TEXCOORD3;
                float4 mulLine3:TEXCOORD4;
            };

            v2f vert (appdata_full v)
            {
                v2f data;
                //��������ת��
                data.pos = UnityObjectToClipPos(v.vertex);
                //��Ļ����ת����ص�����
                data.grabPos = ComputeGrabScreenPos(data.pos);
                //uv���������ص�����
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
                //������ͼuv����
                data.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //���㷴�������
                //1.��������ռ��·�������
                fixed3 wNormal = UnityObjectToWorldNormal(v.normal);
                //2.��������ռ�����������
                fixed3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                //3.��������ռ��¸�����
                fixed3 wbiTangent = cross(normalize(wTangent), normalize(wNormal)) * v.tangent.w;
                //4.��������ռ�������
                fixed3 wpos = mul(unity_ObjectToWorld, v.vertex);
                //������߿ռ䵽����ռ�ľ���
                data.mulLine1 = fixed4(wTangent.x, wbiTangent.x, wNormal.x, wpos.x);
                data.mulLine2 = fixed4(wTangent.y, wbiTangent.y, wNormal.y, wpos.y);
                data.mulLine3 = fixed4(wTangent.z, wbiTangent.z, wNormal.z, wpos.z);
                return data;
            }

            fixed4 frag (v2f i):SV_Target
            {
               //��ȡ����ռ����ӽǷ���
               fixed3 wpos = fixed3(i.mulLine1.z, i.mulLine2.z, i.mulLine3.z);
               fixed3 wViewDir = normalize(UnityWorldSpaceViewDir(wpos));
               //��ȡ���߲�����ɫ
               fixed4 packNormal = tex2D(_BumpTex, i.uv.zw);
               //���ڷ���XYZ������Χ��[-1��1]֮�������RGB������Χ��[0��1]֮��
               //normalTex = normalTex * 2 - 1;
               //Ҳ����ʹ��UnpackNormal�����Է�����Ϣ�����������Լ����ܵĽ�ѹ 
               fixed3 tangentNormal = UnpackNormal(packNormal);
               //��ȡ���߿ռ�ķ���ת��������ռ���(���о���任)
               fixed3 wNormal = float3(dot(i.mulLine1.xyz, tangentNormal), dot(i.mulLine2.xyz, tangentNormal), dot(i.mulLine3.xyz, tangentNormal));
               //��ȡ����ڷ��ߵķ�������
               fixed3 wRefl = reflect(-wViewDir, wNormal);
               //������ص���ɫ
               //��ʵ���Ǵ�����ץȡ�� ��Ļ��Ⱦ�����н��в��� �������
               //ץȡ�����е���ɫ��Ϣ �൱���������������������ɫ              
               //��Ҫ������Ч�� �����ڲ���֮ǰ ����xy��Ļ�����ƫ��
               float2 offset = tangentNormal.xy * _Distortion;
               //xyƫ��һ��λ��
               i.grabPos.xy = offset * i.grabPos.z + i.grabPos.xy;              
               //����͸�ӳ��� ����Ļ����ת���� 0~1��Χ�� Ȼ���ٽ��в���
               fixed2 screenUV = i.grabPos.xy / i.grabPos.w;
               //�Ӳ������Ⱦ�����н��в��� ��ȡ�������ɫ
               fixed4 grabColor = tex2D(_GrabTexture, screenUV);

               //�ڴ˴������uv�Ǿ�����ֵ������ ÿһ��ƬԪ�����Լ���һ��uv����
               //�����Żᾫ׼������ͼ����ȡ����ɫ
               fixed4 mainColor = tex2D(_MainTex, i.uv.xy);
               //��������ɫ����������ɫ���е���
               fixed4 reflColor = texCUBE(_CubeMap, wRefl) * mainColor;
               //����̶� 0~1 0������ȫ���䣨��ȫ�����䣩1������ȫ���䣨͸��Ч�� �൱�ڹ�ȫ���������ڲ���
               fixed4 color = reflColor * (1 - _RefractAmount) + grabColor * _RefractAmount;

               return color;
            }
            ENDCG
        }
    }
}
