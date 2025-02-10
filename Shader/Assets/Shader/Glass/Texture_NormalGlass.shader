//基本玻璃实现带法线
Shader "MyShader/Glass/Texture_NormalGlass"
{
     Properties
    {
        //纹理
        _MainTex("MainTex", 2D) = ""{}
         //法线纹理
        _BumpTex("BumpTex", 2D) = ""{}
        //立方体纹理
        _CubeMap("CubeMap", Cube) = ""{}
        //折射程度(0表示完全不折射-相当于完全反射，1表示完全折射-相当于完全透明)
        _RefractAmount("RefractAmount", Range(0, 1)) = 1   
        //控制折射扭曲的变量
        _Distortion("Distortion", Range(0,10)) = 0
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

            //主材质
            sampler2D _MainTex;
            float4 _MainTex_ST;
            //法线材质
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            //映射屏幕图像存储渲染纹理
            sampler2D _GrabTexture;
            //立方体纹理
            samplerCUBE _CubeMap;
            float _RefractAmount;
            //控制折射扭曲的变量
            float _Distortion;
            struct v2f
            {
                float4 pos:SV_POSITION;
                //也可以直接声明一个float4的成员 xy用于记录颜色纹理的uv，zw用于记录法线纹理的uv
                float4 uv:TEXCOORD0;
                //抓取屏幕坐标
                float4 grabPos:TEXCOORD1;
                //切线空间到世界空间的矩阵
                float4 mulLine1:TEXCOORD2;
                float4 mulLine2:TEXCOORD3;
                float4 mulLine3:TEXCOORD4;
            };

            v2f vert (appdata_full v)
            {
                v2f data;
                //顶点坐标转换
                data.pos = UnityObjectToClipPos(v.vertex);
                //屏幕坐标转换相关的内容
                data.grabPos = ComputeGrabScreenPos(data.pos);
                //uv坐标计算相关的内容
                data.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
                //法线贴图uv坐标
                data.uv.zw = v.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //计算反射光向量
                //1.计算世界空间下法线向量
                fixed3 wNormal = UnityObjectToWorldNormal(v.normal);
                //2.计算世界空间下切线向量
                fixed3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
                //3.计算世界空间下副切线
                fixed3 wbiTangent = cross(normalize(wTangent), normalize(wNormal)) * v.tangent.w;
                //4.计算世界空间下坐标
                fixed3 wpos = mul(unity_ObjectToWorld, v.vertex);
                //获得切线空间到世界空间的矩阵
                data.mulLine1 = fixed4(wTangent.x, wbiTangent.x, wNormal.x, wpos.x);
                data.mulLine2 = fixed4(wTangent.y, wbiTangent.y, wNormal.y, wpos.y);
                data.mulLine3 = fixed4(wTangent.z, wbiTangent.z, wNormal.z, wpos.z);
                return data;
            }

            fixed4 frag (v2f i):SV_Target
            {
               //获取世界空间下视角方向
               fixed3 wpos = fixed3(i.mulLine1.z, i.mulLine2.z, i.mulLine3.z);
               fixed3 wViewDir = normalize(UnityWorldSpaceViewDir(wpos));
               //获取法线材质颜色
               fixed4 packNormal = tex2D(_BumpTex, i.uv.zw);
               //由于法线XYZ分量范围在[-1，1]之间而像素RGB分量范围在[0，1]之间
               //normalTex = normalTex * 2 - 1;
               //也可以使用UnpackNormal方法对法线信息进行逆运算以及可能的解压 
               fixed3 tangentNormal = UnpackNormal(packNormal);
               //获取切线空间的法线转换到世界空间下(进行矩阵变换)
               fixed3 wNormal = float3(dot(i.mulLine1.xyz, tangentNormal), dot(i.mulLine2.xyz, tangentNormal), dot(i.mulLine3.xyz, tangentNormal));
               //获取相对于法线的反射向量
               fixed3 wRefl = reflect(-wViewDir, wNormal);
               //折射相关的颜色
               //其实就是从我们抓取的 屏幕渲染纹理中进行采样 参与计算
               //抓取纹理中的颜色信息 相当于是这个玻璃对象后面的颜色              
               //想要有折射效果 可以在采样之前 进行xy屏幕坐标的偏移
               float2 offset = tangentNormal.xy * _Distortion;
               //xy偏移一个位置
               i.grabPos.xy = offset * i.grabPos.z + i.grabPos.xy;              
               //利用透视除法 将屏幕坐标转换到 0~1范围内 然后再进行采样
               fixed2 screenUV = i.grabPos.xy / i.grabPos.w;
               //从捕获的渲染纹理中进行采样 获取后面的颜色
               fixed4 grabColor = tex2D(_GrabTexture, screenUV);

               //在此处传入的uv是经过插值运算后的 每一个片元都有自己的一个uv坐标
               //这样才会精准的在贴图当中取出颜色
               fixed4 mainColor = tex2D(_MainTex, i.uv.xy);
               //将反射颜色和主纹理颜色进行叠加
               fixed4 reflColor = texCUBE(_CubeMap, wRefl) * mainColor;
               //折射程度 0~1 0代表完全反射（完全不折射）1代表完全折射（透明效果 相当于光全部进入了内部）
               fixed4 color = reflColor * (1 - _RefractAmount) + grabColor * _RefractAmount;

               return color;
            }
            ENDCG
        }
    }
}
