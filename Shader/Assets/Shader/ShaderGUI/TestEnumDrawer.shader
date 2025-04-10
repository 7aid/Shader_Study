Shader "MyShader/ShaderGUI/TestEnumDrawer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //[Enum(tex, 0 , red, 1, green, 2, blue, 3)]_Color("Color", Float) = 0
        //默认存在关键字 
        //_KEYWORDTESTENUM_TEX
        //_KEYWORDTESTENUM_RED
        //_KEYWORDTESTENUM_GREEN
        //_KEYWORDTESTENUM_BLUE
        [KeywordEnum(tex, red, green, blue)]_Color("Color", Float) = 0
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
            #pragma shader_feature _COLOR_TEX _COLOR_RED _COLOR_GREEN _COLOR_BLUE

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
            fixed _Color;

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
			    //if (_Color == 0) 
				   //col = tex2D(_MainTex, i.uv);
       //         else if(_Color == 1)
       //            col = fixed4(1,0,0,1);
       //         else if(_Color == 2)
       //            col = fixed4(0,1,0,1);
       //         else if(_Color == 3)
       //            col = fixed4(0,0,1,1);

                #if defined(_COLOR_TEX) 
				   col = tex2D(_MainTex, i.uv);
                #elif defined(_COLOR_RED)
                   col = fixed4(1,0,0,1);
                 #elif defined(_COLOR_GREEN)
                   col = fixed4(0,1,0,1);
                 #elif defined(_COLOR_BLUE)
                   col = fixed4(0,0,1,1);
                 #else
                   col = fixed4(0,0,0,0);
                 #endif
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
