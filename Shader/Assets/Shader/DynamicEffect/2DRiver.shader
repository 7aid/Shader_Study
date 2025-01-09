//滚动背景
Shader "MyShader/2DRiver"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //叠加的颜色
        _Color("Color",Color) = (1,1,1,1)
        //波动幅度
        _WaveAmplitude("WaveAmplitude", float) = 1
        //波动频率
        _WaveFrequency("WaveFrequency", float) = 1
        //波长的倒数
        _InvWaveLength("InvWaveLength", float) = 1

        //纹理变化速度
        _Speed("Speed", float) = 1

    }
    SubShader
    {   //DisableBatching,是否对SubShader关闭批处理我们在制作顶点动画时，有时需要关闭该Shader的批处理,因为我们在制作顶点动画时，有时需要使用模型空间下的数据
        //而批处理会合并所有相关的模型，这些模型各自的模型空间会丢失，导致我们无法正确使用模型空间下相关数据,在实现流程的2D河流效果时，
        //我们就需要让顶点在模型空间下进行偏移因此我们需要使用该标签，为该Shader关闭批处理
        Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;

            float _Speed;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base o)
            {
                v2f data;
                //模型空间下的偏移位置
                float4 offset;             
                //让它在模型空间的x轴方向进行偏移 (因为此处模型空间下该顶点的流动控制是z轴，正常应该是x轴)
                offset.x = sin(_Time.y * _WaveFrequency + o.vertex.z * _InvWaveLength) * _WaveAmplitude;
                offset.yzw = float3(0,0,0);
                data.pos = UnityObjectToClipPos(o.vertex + offset);
                data.uv = o.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                data.uv += float2(0, _Time.y * _Speed);
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float4 color = tex2D(_MainTex, i.uv);
                color.rgb *= _Color.rgb;
                return color;
            }
            ENDCG
        }
    }
}
