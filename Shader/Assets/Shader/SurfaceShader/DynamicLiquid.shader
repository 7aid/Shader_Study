Shader "MyShader/SurfaceShader/DynamicLiquid"
{
    Properties
    {
        //颜色
        _Color("Color",Color) = (1,1,1,1)
        //高光颜色和光滑度
        _Specular("Specular", Color) = (1,1,1,1)
        //液体高度
        _Height("Height", float) = 0
        //波纹变化速度
        _Speed("_Speed", float) = 1
        //波动幅度
        _WaveAmplitude("WaveAmplitude", float) = 1
        //波动频率
        _WaveFrequency("WaveFrequency", float) = 1
        //波长的倒数
        _InvWaveLength("InvWaveLength", float) = 1
    }
    SubShader
    {
        //设置混合相关
        Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
        Blend DstColor SrcColor
        ZWrite Off

        CGPROGRAM
        #pragma surface surf StandardSpecular noshadow

        #pragma target 3.0

        fixed4 _Color;
        fixed4 _Specular;
        float _Height;
        float _Speed;
        float _WaveAmplitude;
        float _WaveFrequency;
        float _InvWaveLength;

        struct Input{
            //世界空间下像素点坐标
            float3 worldPos;
        };

        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            //将模型空间下中心点转换到世界空间下
            float3 centerPos = mul(unity_ObjectToWorld, float4(0,0,0,1));
            //当前像素点和中心点的高度差
            float liquidHeight = centerPos.y - IN.worldPos.y + _Height * 0.01f;
            //波纹偏移计算 某轴位置偏移量 = sin( _Time.y * 波动频率 + 顶点某轴坐标 * 波长的倒数) * 波动幅度
            float waveOffset = sin(_Time.y * _WaveFrequency + IN.worldPos * _InvWaveLength) * _WaveAmplitude;          
            liquidHeight += waveOffset;
            //如果liquidHeight >= 0 则返回1 如果小于0 则返回0
            //如果是0 就希望被剔除 否则不剔除
            liquidHeight = step(0, liquidHeight);
            //如果liquidHeight是0 - 0.001 肯定小于0 就会被剔除 不会被渲染
            clip(liquidHeight - 0.001);
            //漫反射颜色
            o.Albedo = _Color.rgb;
            //高光颜色
            o.Specular = _Specular.rgb;
            //光滑度设置
            o.Smoothness = _Specular.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
