Shader "MyShader/ShaderDynamicTexture"
{
    Properties
    {
        _ColorA("ColorA", Color) = (1,1,1,1)    
        _ColorB("ColorB", Color) = (1,1,1,1)    
        _CellSize("CellSize", Float) = 8
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }     

        Pass
        {
         CGPROGRAM
        #pragma vertex vert;
        #pragma fragment frag;

        #include "UnityCG.cginc"

        fixed4 _ColorA;
        fixed4 _ColorB;
        float _CellSize;

        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD0;
        };
    
        v2f vert(appdata_base v)
        {
            v2f data;
            data.pos = UnityObjectToClipPos(v.vertex);
            data.uv = v.texcoord.xy;
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //把uv坐标从0~1范围 缩放到 0~_TileCount
            float2 celluv = floor(i.uv * _CellSize);
            //利用奇偶相加规律得到 0、1 值，0代表同奇或同偶，1代表不同
            float value = (celluv.x + celluv.y) % 2;
            //因为value只会是0或1 ，那么我们完全可以利用lerp进行取值
            //取的就是两端的极限值 只有两种情况
            return lerp(_ColorA, _ColorB, value);
        }
        ENDCG
        }      
    }
}
