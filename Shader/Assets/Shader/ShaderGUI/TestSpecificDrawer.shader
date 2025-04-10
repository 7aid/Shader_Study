Shader "MyShader/ShaderGUI/TestSpecificDrawer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HideInInspector]
        _HideInspector("HideInspector", Range(0, 1)) = 0
        [NoScaleOffset]
        _NoScaleOffset("NoScaleOffset", 2D) = "white" {}
        [Normal]
        _Normal("Normal", 2D) = "white" {}
        [HDR]
        _HDR("HDR", Color) = (0,0,0,0)     
        _Space1("Space1", Range(0, 1)) = 0
        [Space(100)]
        _Space2("Space2", Range(0, 1)) = 0
       
        [Header(Pictrue Info)]_HeaderPictrue("HeaderPictrue", 2D) = "white" {}
        [Header(Color Info)]_HeaderColor("HeaderColor", Color) = (0,0,0,0)  
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
                fixed4 col = tex2D(_MainTex, i.uv);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
