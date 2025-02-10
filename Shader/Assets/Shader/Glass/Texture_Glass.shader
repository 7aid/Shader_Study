//基本玻璃实现
Shader "MyShader/Glass/Texture_Glass"
{
    Properties
    {
        //纹理
        _MainTex("MainTex", 2D) = ""{}
        //立方体纹理
        _CubeMap("CubeMap", Cube) = ""{}
        //折射程度(0表示完全不折射-相当于完全反射，1表示完全折射-相当于完全透明)
        _RefractAmount("RefractAmount", Range(0, 1)) = 1
    }
    SubShader
    {   //修改渲染队列为Transparent，但是RenderType渲染类型不修改，因为它本质上还是一个不透明物体
        //以后使用着色器替换功能时，可以在被正常渲染
        Tags{"RenderType" = "Opaque"  "Queue" = "Transparent"}
        //抓取屏幕图像存储渲染纹理
        GrabPass{}
        Pass
        {
            //设置光渲染方式，不透明物体向前渲染
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            //映射屏幕图像存储渲染纹理
            sampler2D _GrabTexture;
            samplerCUBE _CubeMap;
            float _RefractAmount;

            struct v2f
            {
                float4 pos:SV_POSITION;
                //也可以直接声明一个float4的成员 xy用于记录颜色纹理的uv，zw用于记录法线纹理的uv
                float4 uv:TEXCOORD0;
                //抓取屏幕坐标
                float4 grabPos:TEXCOORD1;
                //反射率
                float3 wRefl:TEXCOORD2;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                //顶点坐标转换
                data.pos = UnityObjectToClipPos(v.vertex);
                //屏幕坐标转换相关的内容
                data.grabPos = ComputeGrabScreenPos(data.pos);
                //uv坐标计算相关的内容
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
 
                //计算反射光向量
                //1.计算世界空间下法线向量
                fixed3 wNormal = UnityObjectToWorldNormal(v.normal);
                //2.世界空间下的顶点坐标
                fixed3 wPos = mul(unity_ObjectToWorld, v.vertex);
                //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置 
                fixed3 wViewDir = UnityWorldSpaceViewDir(wPos);
                //4.计算反射向量
                data.wRefl = reflect(-wViewDir, wNormal);
                return data;
            }

            fixed4 frag (v2f i):SV_Target
            {
               //在此处传入的uv是经过插值运算后的 每一个片元都有自己的一个uv坐标
               //这样才会精准的在贴图当中取出颜色
               fixed4 mainColor = tex2D(_MainTex, i.uv);
               //将反射颜色和主纹理颜色进行叠加
               fixed4 reflColor = texCUBE(_CubeMap, i.wRefl) * mainColor;

               //折射相关的颜色
               //其实就是从我们抓取的 屏幕渲染纹理中进行采样 参与计算
               //抓取纹理中的颜色信息 相当于是这个玻璃对象后面的颜色

               //想要有折射效果 可以在采样之前 进行xy屏幕坐标的偏移
               float2 offset = 1 - _RefractAmount;
               //xy偏移一个位置
               i.grabPos.xy = i.grabPos.xy - offset / 10;

               //利用透视除法 将屏幕坐标转换到 0~1范围内 然后再进行采样
               fixed2 screenUV = i.grabPos.xy / i.grabPos.w;
               //从捕获的渲染纹理中进行采样 获取后面的颜色
               fixed4 grabColor = tex2D(_GrabTexture, screenUV);
               //折射程度 0~1 0代表完全反射（完全不折射）1代表完全折射（透明效果 相当于光全部进入了内部）
               fixed4 color = reflColor * (1 - _RefractAmount) + grabColor * _RefractAmount;

               return color;
            }
            ENDCG
        }
    }
}
