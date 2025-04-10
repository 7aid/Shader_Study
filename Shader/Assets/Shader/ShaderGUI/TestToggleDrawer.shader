Shader "MyShader/ShaderGUI/TestToggleDrawer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //默认就会有一个关键字 _SHOWTEX_ON
        //如果想要用toggle来控制关键字的启用与禁用 那么一定需要去声明对应规则的关键字
        [Toggle]_ShowTex("ShowTex", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature _SHOWTEX_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //fixed _ShowTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = fixed4(0,0,0,0);

				//if (_ShowTex == 1)
                //    col = tex2D(_MainTex, i.uv);
			    //else
                //    col = fixed4(1,1,1,1);

                #if defined(_SHOWTEX_ON)
                    col = tex2D(_MainTex, i.uv);
                #else
                    col = fixed4(1,1,1,1);
                #endif

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
