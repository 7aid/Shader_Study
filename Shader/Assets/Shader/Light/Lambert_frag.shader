//半兰伯特光照逐片元光照
Shader "MyShader/Light/Lambert_frag"
{
    Properties
    {
        //材质的漫反射属性
        _LambortColor("_LambortColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "LightModel"  ="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _LambortColor;

            struct v2f
            {
                float4 pos:SV_POSITION;
                fixed3 normal:NORMAL;
            };

            v2f vert (appdata_base data)
            {
                v2f o;   
                o.pos =  UnityObjectToClipPos(data.vertex);
                o.normal = UnityObjectToWorldNormal(data.normal);
                return o;
            }

            fixed4 frag (v2f o) : SV_Target
            {
                fixed3 lightNormalize = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 color = _LightColor0.rgb * _LambortColor.rgb * max(0, dot(lightNormalize, o.normal));
                color = color + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
