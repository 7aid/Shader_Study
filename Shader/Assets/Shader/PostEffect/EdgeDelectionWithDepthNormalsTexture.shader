//纹理深度实现边缘切割效果
Shader "MyShader/EdgeDelectionWithDepthNormalsTexture"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //边缘检测强度 0显示场景 1只显示边缘 用于控制自定义背景色程度
        _EdgeOnly("EdgeOnly", float) = 0
        //描边颜色
        _EdgeColor("EdgeColor", Color) = (1,1,1,1)
        //背景颜色
        _BackgroundColor("BackgroundColor", Color) = (1,1,1,1)
        //采样偏移距离
        _SampleDistance("SampleDistance", float) = 1
        //深度敏感度
        _SensitivityDepth("SensitivityDepth", float) = 1
        //法线灵敏度
        _SensitivityNormal("SensitivityNormal", float) = 1
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
            float4 _MainTex_TexelSize;
            //按规则命名的 深度+法线纹理 变量
            sampler2D _CameraDepthNormalsTexture;
              //用于控制自定义背景颜色程度的 0要显示原始背景色 1只显示边缘 完全显示自定义背景色
            fixed _EdgeOnly;
            //边缘的描边颜色
            fixed4 _EdgeColor;
            //自定义背景颜色
            fixed4 _BackgroundColor;
            //采样偏移程度 主要用来控制描边的粗细 值越大越粗 反之越细
            float _SampleDistance;
            //深度和法线的敏感度 用来进行这个差值判断时 起作用
            float _SensitivityDepth;
            float _SensitivityNormal;

            struct v2f
            {
                float4 vertex:SV_POSITION;   
                //5个uv坐标赋值,中心点、左上角、右下角、右上角、左下角
                half2 uv[5]:TEXCOORD0;
            };

            //用于比较两个点的深度和法线纹理中采样得到的信息 用来判断是否是边缘
            //返回值的含义 
            //1 - 法线和深度值基本相同 处于同一个平面上
            //0 - 差异大 不在一个平面上
            half CheckSameDepthAndNormal(half4 depthNormal1, half4 depthNormal2)
            {
                //分别得到两个点的深度和法线
                float depth1 = DecodeFloatRG(depthNormal1.zw);
                float depth2 = DecodeFloatRG(depthNormal2.zw);
                //得到法线的xy
                float2 normal1 = depthNormal1.xy;
                float2 normal2 = depthNormal2.xy;

                //深度的差异计算
                float depthDiff = abs(depth1 - depth2) * _SensitivityDepth;
                //判断深度是不是很接近 是不是相当于在一个平面上
                //如果满足条件 证明深度值差异非常小 基本趋近于在一个平面上 返回1；否则 返回0
                int isSameDepth = depthDiff < 0.1 * depth1;

                //法线的差异计算
                //计算两条法线的xy的差值 并且乘以 自定义的敏感度
                float2 normalDiff = abs(normal1 - normal2) * _SensitivityNormal;
                //判断两个法线是否在一个平面
                //如果差异不大 证明基本上在一个平面上 返回 1；否则返回0
                int isSameNormal = (normalDiff.x + normalDiff.y) < 0.1; 

                return isSameDepth * isSameNormal;          
            }

            v2f vert(appdata_base v)
            {
               v2f o;
               o.vertex = UnityObjectToClipPos(v.vertex);
               o.uv[0] = v.texcoord;
               o.uv[1] = v.texcoord + _MainTex_TexelSize.xy * half2(-1 , 1) * _SampleDistance;
               o.uv[2] = v.texcoord + _MainTex_TexelSize.xy * half2(1 , -1) * _SampleDistance;
               o.uv[3] = v.texcoord + _MainTex_TexelSize.xy * half2(1 , 1) * _SampleDistance;
               o.uv[4] = v.texcoord + _MainTex_TexelSize.xy * half2(-1 , -1) * _SampleDistance;
               return o;
            }
        
            float4 frag(v2f i):SV_TARGET 
            {
                //获取四个点的深度和法线信息
                half4 TL = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
                half4 BR = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
                half4 TR = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
                half4 BL = tex2D(_CameraDepthNormalsTexture, i.uv[4]);
                //根据深度+法线信息 去判断 是否是边缘
                half edgeLerpValue = 1;

                edgeLerpValue *= CheckSameDepthAndNormal(TL, BR);
                edgeLerpValue *= CheckSameDepthAndNormal(TR, BL);
                
                //通过插值进行颜色变换
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edgeLerpValue);
                
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edgeLerpValue);

                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            ENDCG
        }
    }
    Fallback Off
}
