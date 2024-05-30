//��������  �������� ����ͼ����  ���ַ�
Shader "MyShader/Texture_Mask"
{
    
    Properties
    {
        //��������ɫ
        _MainColor("MainColor", Color) = (1,1,1,1)
        //�߹ⷴ����ɫ
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecularGloss("_SpecularGloss",Range(8, 255)) = 15
        //����ͼ����
        _MainTex("MainTex", 2D) = ""{}
        //��������
        _BumpTex("BumpTex", 2D) = ""{}
        //��͹�̶�
        _BumpScale("BumpScale", Range(0, 2)) = 1
        //��������
        _MaskTex("MaskTex", 2D) = ""{}
        //����ϵ��
        _MaskNum("MaskNum", Float) = 1
    }
    SubShader
    {    
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            sampler2D _BumpTex;
            fixed4 _BumpTex_ST;
            fixed _BumpScale;
            sampler2D _MaskTex;
            fixed4 _MaskTex_ST;
            fixed _MaskNum;

            struct v2f
            {
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;  
               fixed3 tDirLight:TEXCOORD0;
               fixed3 tDirView:TEXCOORD1;
               fixed4 uv:TEXCOORD2;
            };
          
          
            v2f vert (appdata_full full)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(full.vertex);
               //����ͼ����
               data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
               //������ͼ����
               data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
               fixed3 biTangent = cross(normalize(full.tangent), normalize(full.normal)) * full.tangent.w;
               //����ռ�-���߿ռ����
               float3x3 mulW2T = float3x3(
               full.tangent.xyz,
               biTangent,
               full.normal);

               data.tDirLight = mul(mulW2T, ObjSpaceLightDir(full.vertex));
               data.tDirView = mul(mulW2T, ObjSpaceViewDir(full.vertex));
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               //����
               fixed4 normalPack = tex2D(_BumpTex, i.uv.zw);

               fixed3 tNormal = UnpackNormal(normalPack); 
               tNormal.xy *= _BumpScale;
               tNormal.z = sqrt(1.0 - saturate(dot(tNormal.xy, tNormal.xy)));
               //��������ɫ��������������ɫ����
               fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _MainColor.rgb;
               //������������
               fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(normalize(i.tDirLight),normalize(tNormal)));
               //����ֵ = ��������ֵ * ����ϵ��
               fixed maskValue = tex2D(_MaskTex, i.uv.xy).r * _MaskNum;
               //�߹ⷴ��
               fixed3 dirHalf = normalize(i.tDirView) + normalize(i.tDirLight);
               fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(normalize(dirHalf), normalize(tNormal))), _SpecularGloss) * maskValue;
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + specularColor + lambertColor;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
