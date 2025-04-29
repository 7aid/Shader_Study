Shader "MyShader/SurfaceShader/SurfaceShader_01"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("BumpMap", 2D) = "white" {}
        _BumpScale("BumpScale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _BumpScale;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = tex.rgb * _Color.rgb;
            o.Alpha = tex.a * _Color.a;

            //乘以凹凸程度的系数
            float3 tangentNormal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            tangentNormal.xy *= _BumpScale;
            tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));     
            o.Normal = tangentNormal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
