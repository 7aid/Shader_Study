//∞Î¿º≤ÆÃÿπ‚’’÷∆¨‘™π‚’’
Shader "MyShader/Lambert_frag_half"
{
    Properties
    {
        _MainColor ("Texture", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
            };

            fixed4 _MainColor;

            v2f vert (appdata_base baseData)
            {
                v2f data;
                data.position = UnityObjectToClipPos(baseData.vertex);
                data.normal = UnityObjectToWorldNormal(baseData.normal);
                return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               fixed3 color;
               fixed3 lightNormal = normalize(_WorldSpaceLightPos0.xyz);
               color = _LightColor0 * _MainColor * (dot(i.normal, lightNormal ) * 0.5 + 0.5);
               color = color + UNITY_LIGHTMODEL_AMBIENT.rgb;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
