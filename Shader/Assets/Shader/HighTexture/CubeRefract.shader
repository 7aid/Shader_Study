Shader "MyShader/CubeRefract"
{
    Properties
    {
        //������A
        _RefractiveA("RefractiveA", Range(1,2)) = 1
        //������B
        _RefractiveB("_RefractiveB", Range(1,2)) = 1.3
        //����������
        _Cube("CubeMap", Cube) = ""{}
        //����̶�
        _RefractAmount("RefractAmount", Range(0,1)) = 1
    }
  
    SubShader
    {
      Tags {"RenderType" = "Opaque" "Queue" ="Geometry"}
      
      Pass 
      {
        Tags {"LightModel" = "ForwardBase"}

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        float _RefractiveA;
        float _RefractiveB;
        samplerCUBE _Cube;
        float _RefractAmount;

        struct v2f 
        {
            float4 pos:SV_POSITION;//�ü��ռ��¶�������
            //����ռ��·������������ǽ��ѷ��������ļ�����ڶ�����ɫ��������  
            //��Լ���� ����Ч��Ҳ����̫����ۼ����ֱ治����
            float3 worldRefrect:TEXCOORD0;
        };

        v2f vert(appdata_base v)
        {
            v2f data;
            //��������ת��
            data.pos = UnityObjectToClipPos(v.vertex);
            //���㷴�䷽������
            //1.���������¿ռ䷨������
            float3 wNormal = UnityObjectToWorldNormal(v.normal);
            //2.����ռ��¶�������
            fixed3 wPos = mul(unity_ObjectToWorld, v.vertex);
            //3.�����ӽǷ��� �ڲ����������λ�� - ��������λ��
            fixed3 wViewDir = UnityWorldSpaceViewDir(wPos);
            //4.���㷴������
            data.worldRefrect = refract(-normalize(wViewDir), normalize(wNormal), _RefractiveA/_RefractiveB);

            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed4 cubemapColor = texCUBE(_Cube, i.worldRefrect);
            //�ò�����ɫ*������ �������յ���ɫ
            return cubemapColor * _RefractAmount;
        }

        ENDCG
      }
    }
}
