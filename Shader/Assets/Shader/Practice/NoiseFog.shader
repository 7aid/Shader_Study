//噪声雾
Shader "MyShader/Practice/NoiseFog"
{
    Properties
    {   
        //单张纹理信息
        _MainTex ("MainTex", 2D) = ""{}    
        //雾的颜色
        _FogColor("FogColor", Color) = (1,1,1,1)
        //雾的程度
        _FogDensity("FogDensity", float) = 1
        //雾的开始
        _FogStart("FogStart", float) = 0
        //雾最浓的地方
        _FogEnd("FogEnd", float) = 10
        //决定不均匀的噪声纹理
        _Noise("Noise", 2D) = ""{}
        //噪声值偏移系数
        _NoiseAmount("NoiseAmount", Range(0, 1)) = 0.5
        //噪声值X轴移动速度
        _FogXSpeed("FogXSpeed", Range(-0.1, 0.1)) = 0.01
        //噪声值Y轴移动速度
        _FogYSpeed("FogYSpeed", Range(-0.1, 0.1)) = 0.01
    }
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off

        Pass
        {  
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            //纹理
            sampler2D _MainTex;
            float2 _MainTex_TexelSize;
            float4 _FogColor;
            float _FogDensity;
            float _FogStart;
            float _FogEnd;
            //该矩阵只是用于存储向量 0-左下 1-右下 2-右上 3-左上
            float4x4 _RayMatrix;
            sampler2D _CameraDepthTexture;

            sampler2D _Noise;
            float _NoiseAmount;
            float _FogXSpeed;
            float _FogYSpeed;
           
            struct v2f
            {
                //裁剪空间坐标
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float4 uv_depth:TEXCOORD1;
                float4 ray:TEXCOORD2;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;
                float index = 0;
				if (o.uv.x < 0.5 && o.uv.y < 0.5)   
				  index = 0;
                else if(o.uv.x > 0.5 && o.uv.y < 0.5)
                  index = 1;
                else if(o.uv.x > 0.5 && o.uv.y > 0.5)
                  index = 2;
                else
                  index = 3;
                //判断 是否需要进行纹理翻转 如果翻转了 深度的uv和对应顶点需要变化
                #if UNITY_UV_STARTS_AT_TOP
				  if (_MainTex_TexelSize.y < 0)
                  {
                     o.uv_depth.y = 1 - o.uv_depth.y;
                     index = 3 - index;
                  }                  
                #endif
                //根据顶点的位置 决定使用那一个射线向量
                o.ray = _RayMatrix[index];
                return o;

            }

            fixed4 frag (v2f i) : SV_Target
            {          
                //观察空间下 离摄像机的实际距离（Z分量）
                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));
                //世界空间下像素坐标
                float3 wpos = _WorldSpaceCameraPos + linearDepth * i.ray;
                //噪声偏移采样以及偏移
                float2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
                //噪声纹理中采样 采样出来的结果是0~1 
                //我们需要将其转为 -0.5~0.5 然后还可以通过自定义系数控制这个正负范围
                float noise = (tex2D(_Noise, i.uv + speed).r - 0.5) * _NoiseAmount;
                //雾的相关计算
                //混合因子
                float f = (_FogEnd - wpos.y) / (_FogEnd - _FogStart);
                //取0-1之间 超过会取极值
                //之所以乘以1 + noise，是为了在正常计算出来的混合因子中去进行 上下的扰动
                f = saturate(f * _FogDensity * (1 + noise));
                //利用插值 在两个颜色之间进行融合
                fixed3 color = lerp(tex2D(_MainTex, i.uv).rgb, _FogColor.rgb, f);
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    Fallback Off
}
