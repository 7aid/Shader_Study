//���߿ռ��� ʵ�ַ�������shader
Shader "MyShader/Texture_Diffuse"
{
    Properties
    {   //������������ɫ
        _MainColor("MainColor",Color) = (1,1,1,1)
        //����������Ϣ
        _MainTex ("Texture", 2D) = ""{}
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
                //UV���� xyΪ����ͼuv����  zwΪ������ͼuv����
                fixed4 uv:TEXCOORD0;
                //���߿ռ��¹�ķ���
                fixed3 lightDir:TEXCOORD1;
                //���߿ռ����ӽǷ���
                fixed3 viewDir:TEXCOORD2;
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
          

            v2f vert (appdata_full full)
            {
                data.pos = UnityObjectToClipPos(full.vertex);
                //����ͼuv����
                data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //������ͼuv����
                data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //������
                fixed3 tangentMinor = cross(full.normal, full.tangent);
                //����
                fixed3x3 mulM2T = (full.normal, tangentMinor, full.tangent);

            }

            fixed4 frag (v2f data) : SV_Target
            {

            }
            ENDCG
        }
    }
}
