Shader "MyShader/CubeReflect"
{
    Properties
    {
        //����������
        _Cube("CubeMap", Cube) = ""{}
        //������
        _Reflectivity("Reflectivity", Range(0,1)) = 1
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

        samplerCUBE _Cube;
        float _Reflectivity;

        struct v2f 
        {
            float4 pos:SV_POSITION;//�ü��ռ��¶�������
            //����ռ��·������������ǽ��ѷ��������ļ�����ڶ�����ɫ��������  
            //��Լ���� ����Ч��Ҳ����̫����ۼ����ֱ治����
            float3 worldRefl:TEXCOORD0;
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
            data.worldRefl = reflect(-wViewDir, wNormal);

            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed4 cubemapColor = texCUBE(_Cube, i.worldRefl);
            //�ò�����ɫ*������ �������յ���ɫ
            return cubemapColor * _Reflectivity;
        }

        ENDCG
      }
    }
}
