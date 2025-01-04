Shader "MyShader/Texture_Mirror"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "" {}
    }
    SubShader
    {
        Tags{"LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f_img vert (appdata_base v)
            {
                v2f_img data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.wz;
                data.uv.x = 1 - data.uv.x; 
                //data.uv = TRANSFORM_UV(v.texcoord.xy, _MainTex);
                return data;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                //�ڴ˴������uv�Ǿ�����ֵ������ ÿһ��ƬԪ�����Լ���һ��uv����
                //�����Żᾫ׼������ͼ����ȡ����ɫ
               fixed4 color = tex2D(_MainTex, i.uv);
               return color;
            }
            ENDCG
        }
    }
}
