//纹理深度实现运动模糊
Shader "MyShader/MotionBlurWithDepthTexture"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //模糊偏移
        _BlurSize("BlurSize", float) = 0.5
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            //按规则命名的 深度纹理变量
            sampler2D _CameraDepthTexture;
            float _BlurSize;
            //当前帧裁剪到世界空间变换矩阵
            float4x4 _ClipToWorldMatrix;
            //上一帧世界到裁剪空间变换矩阵
            float4x4 _FrontWorldToClipMatrix;

            struct v2f
            {
                float4 vertex:SV_POSITION;    
                float2 uv:TEXCOORD0;
                float2 uv_depth:TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
               v2f o;
               o.vertex = UnityObjectToClipPos(v.vertex);
               o.uv = v.texcoord;
               o.uv_depth = v.texcoord;
               #if UNITY_UV_STARTS_AT_TOP
                   if(_MainTex_TexelSize.y < 0)
                      o.uv_depth.y = 1 - o.uv_depth.y;
               #endif
               return o;
            }
        
            float4 frag(v2f i):SV_TARGET 
            {
                //非线性的 裁剪空间下的深度值
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
                //获取第一个点
                float4 nowClipPos = fixed4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, depth * 2 - 1, 1);
                //获取第一个点的世界空间坐标
                float4 wpos = mul(_ClipToWorldMatrix, nowClipPos);
                //进行透视除法
                wpos /= wpos.w;
                //获取第二个点（上一帧的点）
                float4 frontClipPos = mul(_FrontWorldToClipMatrix, wpos);
                frontClipPos /= frontClipPos.w;
                //获取运动方向
                float2 moveDir = (nowClipPos.xy - frontClipPos.xy) / 2;
                //进行模糊出路
                float2 uv = i.uv;
                float4 color = float4(0,0,0,0);

				for (int j = 0; j < 3; j++)
				{
					 //第一次采样累加的是当前像素所在位置的颜色
                    //第二次采样累加的是当前像素进行了 moveDir * _BlurSize 偏移后的颜色
                    //第二次采样累加的是当前像素进行了 2*moveDir * _BlurSize 偏移后的颜色
                    color += tex2D(_MainTex, uv);
                    uv += moveDir * _BlurSize;
				}
                //计算叠加3次后颜色的平均值 相当于就是在进行模糊处理了
                color /= 3;
                //返回模糊处理后的颜色
                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }

    Fallback Off
}
