//���������������Ӱ
Shader "MyShader/CubeLambortRefract"
{
    Properties
    {
        //������A/B
        _Refractive("Refractive", Range(0.1,1)) = 0.7
        //����������
        _Cube("CubeMap", Cube) = ""{}
        //����̶�
        _RefractAmount("RefractAmount", Range(0,1)) = 1
        //��������ɫ
        _LambertColor("LambertColor", Color) = (1,1,1,1)
        //������ɫ
        _RefractColor("RefractColor", Color) = (1,1,1,1)
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

        float _Refractive;
        samplerCUBE _Cube;
        float _RefractAmount;
        fixed4 _LambertColor;
        fixed4 _RefractColor;

        struct v2f 
        {
            float4 pos:SV_POSITION;//�ü��ռ��¶�������
            //����ռ��·������������ǽ��ѷ��������ļ�����ڶ�����ɫ��������  
            //��Լ���� ����Ч��Ҳ����̫����ۼ����ֱ治����
            float3 worldRefrect:TEXCOORD0;

            fixed3 wPos:TEXCOORD1;

            fixed3 wNormal:NORMAL;

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
            data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            //3.�����ӽǷ��� �ڲ����������λ�� - ��������λ��
            fixed3 wViewDir = UnityWorldSpaceViewDir(data.wPos);
            //4.���㷴������
            data.worldRefrect = refract(-normalize(wViewDir), normalize(data.wNormal), _Refractive);

            TRANSFER_SHADOW(data);
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //���������������ö�Ӧ�ķ����������в���
            fixed3 wLightDir = UnityWorldSpaceLightDir(i.wPos);
            fixed3 diffuseColor = _LightColor0.rgb * _LambertColor.rgb * max(0, dot(normalize(i.wNormal), normalize(wLightDir)));
        
            fixed3 cubemapColor = texCUBE(_Cube, i.worldRefrect).rgb * _RefractColor.rgb;

            UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);
            //�ò�����ɫ*������ �������յ���ɫ
            fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuseColor, cubemapColor, _RefractAmount) * atten;
            return fixed4(color, 1.0);
        }

        ENDCG
      }

    }  
    Fallback "Reflective/VertexLit"
}
