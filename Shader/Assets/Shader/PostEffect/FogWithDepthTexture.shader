//�������ȫ����Ч�����߿ռ��� ʵ�ַ�������shader��
Shader "MyShader/FogWithDepthTexture"
{
    Properties
    {   
        //����������Ϣ
        _MainTex ("MainTex", 2D) = ""{}    
        //�����ɫ
        _FogColor("FogColor", Color) = (1,1,1,1)
        //��ĳ̶�
        _FogDensity("FogDensity", float) = 1
        //��Ŀ�ʼ
        _FogStart("FogStart", float) = 0
        //����Ũ�ĵط�
        _FogEnd("FogEnd", float) = 10
    }
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {  
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            //����
            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            float4 _FogColor;
            float _FogDensity;
            float _FogStart;
            float _FogEnd;
            //�þ���ֻ�����ڴ洢���� 0-���� 1-���� 2-���� 3-����
            float4x4 _RayMatrix;
            sampler2D _CameraDepthTexture;
           
            struct v2f
            {
                //�ü��ռ�����
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 uv_depth:TEXCOORD1;
                float4 ray:TEXCOORD2;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;
                float index = 0;
				if (o.uv.x < 0.5 && o.uv.y < 0.5)   
				  index = 0;
                else if(o.uv.x > 0.5 && o.uv.y < 0.5)
                  index = 1;
                else if(o.uv.x > 0.5 && o.uv.y > 0.5)
                  index = 2;
                else
                  index = 3;
                //�ж� �Ƿ���Ҫ��������ת �����ת�� ��ȵ�uv�Ͷ�Ӧ������Ҫ�仯
                #if UNITY_UV_STARTS_AT_TOP
				  if (_MainTex_TexelSize.y < 0)
                  {
                     o.uv_depth.y = 1 - o.uv_depth.y;
                     index = 3 - index;
                  }                  
                #endif
                //���ݶ����λ�� ����ʹ����һ����������
                o.ray = _RayMatrix[index];
                return o;

            }

            fixed4 frag (v2f i) : SV_Target
            {          
                //�۲�ռ��� ���������ʵ�ʾ��루Z������
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
                //����ռ�����������
                float3 wpos = _WorldSpaceCameraPos + linearDepth * i.ray;

                //�����ؼ���
                //�������
                float f = (_FogEnd - wpos.y) / (_FogEnd - _FogStart);
                //ȡ0-1֮�� ������ȡ��ֵ
                f = saturate(f * _FogDensity);
                //���ò�ֵ ��������ɫ֮������ں�
                fixed3 color = lerp(tex2D(_MainTex, i.uv).rgb, _FogColor.rgb, f);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    Fallback Off
}
