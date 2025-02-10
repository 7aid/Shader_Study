//高斯模糊效果
Shader "MyShader/PostEffect/GaussianBlur"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //高斯公式偏移半径
        _BlurSpeed("BlurSpeed", float) = 1
    }
    SubShader
    {   
          //用于包裹共用代码 在之后的多个Pass当中都可以使用的代码
          CGINCLUDE   
        
          #include "UnityCG.cginc"

          sampler2D _MainTex;
          //纹素 x=1/宽  y=1/高
          float4 _MainTex_TexelSize;
          float _BlurSpeed;

          struct v2f
          {
             //顶点在裁剪空间下坐标
             float4 vertex:SV_POSITION;
             //5个像素的uv坐标偏移
             half2 uv[5]:TEXCOORD0;
          };

          //片元着色器函数
          //两个Pass可以使用同一个 我们把里面的逻辑写的通用即可
          fixed4 fragBlur(v2f i):SV_TARGET
          {
              //卷积运算
              //卷积核 其中的三个数 因为只有这三个数 没有必要声明为5个单位的卷积核
              float weight[3] = {0.4026, 0.2442, 0.0545};
              //计算当前像素点
              fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

               //去计算左右偏移1个单位的 和 左右偏移两个单位的 对位相乘 累加
			  for (int j = 1; j < 3; j++)
			  {
                  //要和右元素相乘
                  sum += tex2D(_MainTex, i.uv[j * 2 - 1]).rgb * weight[j];
                  //和左元素相乘
                  sum += tex2D(_MainTex, i.uv[j * 2]).rgb * weight[j];
			  }

             return fixed4(sum, 1);
          }
         
         ENDCG

         Tags {"RenderType"="Opaque"}

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
                    
         Pass
         {
             Name "GAUSSIAN_BLUR_HORIZONTAL"
             CGPROGRAM
             #pragma vertex vertBlurHorizontal
             #pragma fragment fragBlur

             //水平方向的顶点着色器

             v2f vertBlurHorizontal(appdata_base v)
             {
                 v2f o;
                 o.vertex = UnityObjectToClipPos(v.vertex);
                 half2 uv = v.texcoord;
                 //去进行5个像素 水平位置的偏移获取
                 o.uv[0] = uv;
                 o.uv[1] = uv + half2(_MainTex_TexelSize.x * 1, 0) * _BlurSpeed;
                 o.uv[2] = uv - half2(_MainTex_TexelSize.x * 1, 0) * _BlurSpeed;
                 o.uv[3] = uv + half2(_MainTex_TexelSize.x * 2, 0) * _BlurSpeed;
                 o.uv[4] = uv - half2(_MainTex_TexelSize.x * 2, 0) * _BlurSpeed;

                 return o;

             }
             ENDCG
         
         }

        Pass
        {
            Name "GAUSSIAN_BLUR_VERTICAL"
             CGPROGRAM
             #pragma vertex vertBlurVertical
             #pragma fragment fragBlur

             //垂直方向的顶点着色器

             v2f vertBlurVertical(appdata_base v)
             {
                 v2f o;
                 o.vertex = UnityObjectToClipPos(v.vertex);
                 half2 uv = v.texcoord;
                 //去进行5个像素 水平位置的偏移获取
                 o.uv[0] = uv;
                 o.uv[1] = uv + half2(0, _MainTex_TexelSize.x * 1) * _BlurSpeed;
                 o.uv[2] = uv - half2(0, _MainTex_TexelSize.x * 1) * _BlurSpeed;
                 o.uv[3] = uv + half2(0, _MainTex_TexelSize.x * 2) * _BlurSpeed;
                 o.uv[4] = uv - half2(0, _MainTex_TexelSize.x * 2) * _BlurSpeed;

                 return o;

           }
           ENDCG
         
         }
     
    }

    Fallback Off
}
