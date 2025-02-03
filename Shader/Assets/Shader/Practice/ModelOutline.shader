Shader "MyShader/ModelOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //��Ե����ɫ
        _OutlineColor("OutlineColor", Color) = (1,1,1,1)
        //��Ե�ߴ�ϸ
        _OutlineWidth("OutlineWidth", float) = 0.01
    }
    SubShader
    {
        Tags {"RenderType" = "Opaque" "Queue"="Transparent"}

        Pass
        {
            //�ر����д�� Ŀ���� �ڶ���Pass�ܹ������غϵĵط�
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vert (appdata_base v)
            {
                v2f o;
                ////ƫ�ƶ���λ�� �����߷���ƫ��
                //�����ǵĶ��㳯���߷��� ƫ�� �Զ������λ ����Զ������ ���Ǿ���ģ�����Ͷ��ٵ� �Ϳ��Ծ�����Ե�ߵĴ�ϸ
                float3 newVertex = v.vertex + normalize(v.normal) * _OutlineWidth;
                //�����͹���Ķ���ת���ü��ռ�
                o.vertex = UnityObjectToClipPos(float4(newVertex.xyz, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
