//���������������������Ӱ
Shader "MyShader/CubeLambortFresnelReflect"
{
    Properties
    {
        //����������
        _Cube("CubeMap", Cube) = ""{}
        //������
        _Reflectivity("Reflectivity", Range(0,1)) = 1
        //����ɫ
        _Color("Color", Color) = (1,1,1,1)
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

        samplerCUBE _Cube;
        float _Reflectivity;
        fixed4 _Color;

        struct v2f 
        {
            float4 pos:SV_POSITION;//�ü��ռ��¶�������
            //����ռ��·������������ǽ��ѷ��������ļ�����ڶ�����ɫ��������  
            //��Լ���� ����Ч��Ҳ����̫����ۼ����ֱ治����
            float3 worldRefl:TEXCOORD0;

            fixed3 wNormal:NORMAL;

            fixed3 wViewDir:TEXCOORD1;
             
            float4 wPos:TEXCOORD2;
            SHADOW_COORDS(3)
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
            data.wViewDir = UnityWorldSpaceViewDir(data.wPos);
            //4.���㷴������
            data.worldRefl = reflect(-data.wViewDir, data.wNormal);

            TRANSFER_SHADOW(data);
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed3 cubemapColor = texCUBE(_Cube, i.worldRefl).rgb;

            float fresnel = _Reflectivity + (1 - _Reflectivity) * Pow5(1 - dot(normalize(i.wViewDir), normalize(i.wNormal)));

            fixed3 wLightDir = UnityWorldSpaceLightDir(i.wPos);
            fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * max(0, dot(normalize(i.wNormal), normalize(wLightDir)));
			UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);
            //�ò�����ɫ*������ �������յ���ɫ
            fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuseColor, cubemapColor, fresnel) * atten;
            return fixed4(color, 1.0);
        }

        ENDCG
      }
    }

    Fallback "Reflective/VertexLit"
}
