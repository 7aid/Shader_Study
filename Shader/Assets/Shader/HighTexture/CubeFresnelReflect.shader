//����������
Shader "MyShader/CubeFresnelReflect"
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

            fixed3 wNormal:NORMAL;

            fixed3 wViewDir:TEXCOORD1;
        };

        v2f vert(appdata_base v)
        {
            v2f data;
            //��������ת��
            data.pos = UnityObjectToClipPos(v.vertex);
            //���㷴�䷽������
            //1.���������¿ռ䷨������
            data.wNormal = UnityObjectToWorldNormal(v.normal);
            //2.����ռ��¶�������
            fixed3 wPos = mul(unity_ObjectToWorld, v.vertex);
            //3.�����ӽǷ��� �ڲ����������λ�� - ��������λ��
            data.wViewDir = UnityWorldSpaceViewDir(wPos);
            //4.���㷴������
            data.worldRefl = reflect(-data.wViewDir, data.wNormal);
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed4 cubemapColor = texCUBE(_Cube, i.worldRefl);

            float fresnel = _Reflectivity + (1 - _Reflectivity) * Pow5(1 - dot(normalize(i.wViewDir), normalize(i.wNormal)));
            //�ò�����ɫ*������ �������յ���ɫ
            return cubemapColor * fresnel;
        }

        ENDCG
      }
    }
}
