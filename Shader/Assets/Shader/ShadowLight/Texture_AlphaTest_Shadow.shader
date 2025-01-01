//͸��������Ӱ  ͸����ֵ
Shader "MyShader/Texture_AlphaTest_Shadow"
{
    Properties
    {   //������������ɫ
        _Color("Color",Color) = (1,1,1,1)
        //����������Ϣ
        _MainTex ("MainTex", 2D) = ""{}
        //�߹ⷴ����ɫ
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecularNum("SpecularNum", Range(0,20)) = 5
        //͸������ֵ
        _Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
         //������Ⱦ����˳��  ����Ͷ����ͶӰ������͸��Ч����Ҫ���ã�   ������Ⱦ���ͱ�ǩֵΪ͸���и�
        Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
        Pass
        {
            
            Tags {"LightMode" = "ForwardBase"}

            Cull Off


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                //�ü��ռ�����
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //���ǿ��Ե�������������float2�ĳ�Ա���ڼ�¼ ��ɫ�ͷ��������uv����
                //Ҳ����ֱ������һ��float4�ĳ�Ա xy���ڼ�¼��ɫ�����uv��zw���ڼ�¼���������uv
                float4 uv:TEXCOORD0;
                //����ռ䷨��
                fixed3 normal:NORMAL;
                //����ռ����
                fixed3 dirLight:TEXCOORD1;
                //����ռ��ӽ�
                fixed3 dirView:TEXCOORD2;
                //����ռ��ӽ�
                fixed3 wpos:TEXCOORD3;
                SHADOW_COORDS(4)
            };
            //������������ɫ
            float4 _Color;
            //����
            sampler2D _MainTex;
            //��������ź�ƫ��
            float4 _MainTex_ST;
            //�߹ⷴ����ɫ
            fixed4 _SpecularColor;
            //�߷������
            float _SpecularNum;
            //͸������ֵ
            fixed _Cutoff;

            v2f vert (appdata_base base)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(base.vertex);
               //����ͼuv����
                data.uv.xy = base.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                data.normal = UnityObjectToWorldNormal(base.normal);
                data.dirLight = normalize(WorldSpaceLightDir(base.vertex));
                data.dirView = normalize(WorldSpaceViewDir(base.vertex));
                data.wpos = mul(unity_ObjectToWorld, base.vertex);
                //�����ת��
                TRANSFER_SHADOW(data);

                return data;
            }

            fixed4 frag (v2f data) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, data.uv.xy);
                //������ֵ�ü����
				clip(texColor.a - _Cutoff);
                //������ɫ��Ҫ�������������ɫ���е��Ӽ���
                fixed3 albedo = texColor.rgb * _Color.rgb;
                //��ȡ�����������������ɫ
                fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(normalize(data.normal), data.dirLight));
                //��ȡ�Խ������ı�׼��
                fixed3 halfDir = normalize(data.dirView + data.dirLight);
                //��ȡ���ַ��߹ⷴ����ɫ
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(data.normal, halfDir)), _SpecularNum);            
                //����˥������
                UNITY_LIGHT_ATTENUATION(atten, data, data.wpos);
               
                //��ȡ���ַ�����ģ��
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + (lambertColor + specularColorBack) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"

}
