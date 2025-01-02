//�������뷴���ϣ�����yiny��
Shader "MyShader/LambortReflect"
{
    Properties
    {
        //��������������ɫ
        _LambortColor("LambortColor", Color) = (1,1,1,1)
        //������ɫ
        _ReflectColor("ReflectColor", Color) = (1,1,1,1)
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
        #pragma multi_compile_fwdBase

        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        fixed4 _LambortColor;
        fixed4 _ReflectColor;
        samplerCUBE _Cube;
        float _Reflectivity;

        struct v2f 
        {
            float4 pos:SV_POSITION;//�ü��ռ��¶�������
            //����ռ��·������������ǽ��ѷ��������ļ�����ڶ�����ɫ��������  
            //��Լ���� ����Ч��Ҳ����̫����ۼ����ֱ治����
            fixed3 wNormal:NORMAL;
            float3 worldRefl:TEXCOORD0;
            //��������
            fixed3 wPos:TEXCOORD1;
            SHADOW_COORDS(2)
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
            data.wPos = mul(unity_ObjectToWorld, v.vertex);
            //3.�����ӽǷ��� �ڲ����������λ�� - ��������λ��
            fixed3 wViewDir = UnityWorldSpaceViewDir(data.wPos);
            //4.���㷴������
            data.worldRefl = reflect(-wViewDir, data.wNormal);

            TRANSFER_SHADOW(data);
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed4 cubemapColor = texCUBE(_Cube, i.worldRefl);
            fixed3 wLightDir = UnityWorldSpaceLightDir(i.wPos);
            //��������ɫ
            fixed3 diffuseColor = _LightColor0.rgb * _LambortColor.rgb * max(0, dot(normalize(wLightDir) ,normalize(i.wNormal)));
            UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);       
            //�ò�����ɫ*������ �������յ���ɫ         
            fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuseColor, cubemapColor, _Reflectivity) * atten;
            return fixed4(color, 1.0);
        }

        ENDCG
      }
    }
    Fallback "Reflective/VetexLit"
}
