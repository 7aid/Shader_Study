Shader "MyShader/MovingLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //����ӵ���ɫ Ĭ��ͼƬʱ��ɫ ���ǵ���һ���Զ�����ɫ ���Ըı���
        _Color("Color", Color) = (1,1,1,1)
        //�����ƶ����ٶ�
        _Speed("Speed", Range(1,10)) = 1
        //�����ƶ��ķ���
        [KeywordEnum(X, Y)] _MoveDirection("MoveDirection", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        //ֱ�ӵ�����ɫ ����Ч������ ��������ĸо�
        Blend One One 
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float _Speed;
            
            fixed _MoveDirection;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //����ʱ�� ����UV����ƫ�� ����x��u������Ϳ��Կ����ƶ���Ч����
                #if _MoveDirection_X
                   i.uv = float2(i.uv.x + _Time.x * _Speed, i.uv.y);
                #else
                   i.uv = float2(i.uv.x, i.uv.y + _Time.x * _Speed);
                #endif
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
