//屏幕边缘处理效果
Shader "MyShader/PostEffect/EdgeDelection"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //边缘颜色
        _EdgeColor("EdgeColor", Color) = (1,1,1,1)
        //0表示保留图片原始颜色，1表示完全抛弃图片原始颜色
        _BackGroundExtent("BackGroundExtent",Range(0,1)) = 1
        //替换图片原始颜色的颜色
        _BackGroundColor("BackGroundColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}

        Pass
        {           
            //开启深度测试
            ZTest Always
            //关闭剔除
            Cull Off
            //关闭深度写入
            ZWrite Off
            //因为屏幕后处理效果相当于在场景上绘制了一个与屏幕同宽高的四边形面片
            //这样做的目的是避免它"挡住"后面的渲染物体
            //比如我们在OnRenderImage前加入[ImageEffectOpaque]特性时
            //透明物体会晚于该该屏幕后处理效果渲染，如果不关闭深度写入会影响后面的透明相关Pass

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float4 _EdgeColor;
            float4 _BackGroundColor;
            float _BackGroundExtent;

            struct v2f
            {
                float4 vertex:SV_POSITION;
                //用于存储9个像素uv坐标的变量
                half2 uv[9]:TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f data;
                data.vertex = UnityObjectToClipPos(v.vertex);
                //获取当前顶点的纹理坐标
                half2 uv = v.texcoord;
                //获取周围8个点的偏移计算
                data.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1,-1);
                data.uv[1] = uv + _MainTex_TexelSize.xy * half2(0,-1);
                data.uv[2] = uv + _MainTex_TexelSize.xy * half2(1,-1);
                data.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,0);
                data.uv[4] = uv + _MainTex_TexelSize.xy * half2(0,0);
                data.uv[5] = uv + _MainTex_TexelSize.xy * half2(0,1);
                data.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1,1);
                data.uv[7] = uv + _MainTex_TexelSize.xy * half2(1,0);
                data.uv[8] = uv + _MainTex_TexelSize.xy * half2(1,1);
                return data;
            }

            //计算灰度值
            float calcLuminance(fixed4 color)
            {
                return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;
            }
            
            //计算Sobel算子相关的卷积计算
            half sobel(v2f i)
            {
                //Sobel算子对应的两个卷积核
                half Gx[9] = {-1,-2,-1,
                               0, 0, 0,
                               1, 2, 1};
                 half Gy[9] = {-1,-2,-1,
                               0, 0, 0,
                               1, 2, 1};
                half L; //灰度值
                half edgeX = 0; //水平方向梯度值
                half edgeY = 0; //数值方向梯度值
				for (int j = 0; j < 9; j++)
				{
                    L = calcLuminance(tex2D(_MainTex, i.uv[j]));
					edgeX += L * Gx[j];
                    edgeY += L * Gy[j];
				}

                //梯度值 G = abs(Gx) + abs(Gy)
                return abs(edgeX) + abs(edgeY);
            }

            float4 frag(v2f i):SV_TARGET 
            {
                //利用索贝尔算子计算梯度值
                half edge = sobel(i);   
                //利用计算出来的梯度值在原始颜色 和边缘线颜色之间进行插值
                fixed4 withEdgeColor = lerp(tex2D(_MainTex, i.uv[4]), _EdgeColor , edge);  
                //纯色上描边
                fixed4 onlyEdgeColor = lerp(_BackGroundColor, _EdgeColor, edge);
                //通过程度变量 去控制 是纯色描边 还是 原始颜色描边 在两者之间 进行过渡
                return lerp(withEdgeColor, onlyEdgeColor, _BackGroundExtent);
            }
            ENDCG
        }
    }

    Fallback Off
}
