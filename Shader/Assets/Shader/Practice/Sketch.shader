//素描
Shader "MyShader/Practice/Sketch"
{
    Properties
    {
        //整体颜色叠加
        _Color("Color", Color) = (1,1,1,1)
        //平铺纹理的系数
        _TileFactor("TileFactor", Float) = 1
        //6张素描纹理贴图
        _Sketch0("Sketch0", 2D) = ""{}
        _Sketch1("Sketch1", 2D) = ""{}
        _Sketch2("Sketch2", 2D) = ""{}
        _Sketch3("Sketch3", 2D) = ""{}
        _Sketch4("Sketch4", 2D) = ""{}
        _Sketch5("Sketch5", 2D) = ""{}
        //边缘线相关参数
         //边缘线颜色
        _OutlineColor("OutlineColor", Color) = (1,1,1,1)
        //边缘线粗细
        _OutlineWidth("OutlineWidth", float) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        UsePass "MyShader/Practice/ModelOutline/PASS_OUTLINE"
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //记录素描纹理权重1
                fixed3 weights1 : TEXCOORD1;
                //记录素描纹理权重2
                fixed3 weights2 : TEXCOORD2;
                float3 wpos:TEXCOORD3;
                SHADOW_COORDS(4)
            };

            fixed4 _Color;
            float _TileFactor;

            sampler2D _Sketch0;
            sampler2D _Sketch1;
            sampler2D _Sketch2;
            sampler2D _Sketch3;
            sampler2D _Sketch4;
            sampler2D _Sketch5;
            

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //uv坐标平铺缩放 让纹理*平铺系数
                o.uv = v.texcoord.xy * _TileFactor;
                //世界空间光照方向
                fixed3 wLightDir = normalize(WorldSpaceLightDir(v.vertex));
                //世界空间法线转换
                fixed3 wNormal = UnityObjectToWorldNormal(v.normal);
                //兰伯特漫反射光照强度 0-1
                //光线方向 → wLightDir   表面法线 → wNormal
                //\      |      /
                // \     |θ    /
                //  \    |    /
                //   \   |   /
                //    \  |  /
                //     \ | /
                //      \|/
                //-------表面-------
                //θ越小 → diff越大（越亮）
                //θ≥90° → diff=0（无光照）
                //max: 将结果限制在0或更大的值，确保光照强度非负。负值意味着光源在背面，此时漫反射贡献为0
                fixed diff = max(0, dot(wLightDir, wNormal));
                //将光照系数 从 0~1 扩充到 0~7
                diff = diff * 7.0;
                //初始化权重 默认每一张素描纹理对应的权重都是0
                o.weights1 = fixed3(0,0,0);
                o.weights2 = fixed3(0,0,0);
                //代表6张图的权重都会是0 那么采样就不会使用6张图的颜色
				if (diff > 6.0) 
				{ 
					//最亮的部分，不需要改变任何权重
				}
                else if(diff > 5.0) //代表 会从第1张图中采样 因此对应权重不会为0
                {
                    o.weights1.x = diff - 5.0;
                }
                else if(diff > 4.0) //代表 会从第1,2张图中采样 因此对应权重不会为0
                {
                    o.weights1.x = diff - 4.0;
                    o.weights1.y = 1 - o.weights1.x;
                }
                else if(diff > 3.0) //代表 会从第2,3张图中采样 因此对应权重不会为0
                {
                    o.weights1.y = diff - 3.0;
                    o.weights1.z = 1 - o.weights1.y;
                }
                else if(diff > 2.0) //代表 会从第3,4张图中采样 因此对应权重不会为0
                {
                    o.weights1.z = diff - 2.0;
                    o.weights2.x = 1 - o.weights1.z;
                }
                else if(diff > 1.0) //代表 会从第4,5张图中采样 因此对应权重不会为0
                {
                    o.weights2.x = diff - 1.0;
                    o.weights2.y = 1 - o.weights2.x;
                }
                else //代表 会从第5,6张图中采样 因此对应权重不会为0
                {
                    o.weights2.y = diff;
                    o.weights2.z = 1 - diff;
                }
                 //顶点坐标转世界坐标
                o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //如果在顶点着色器中计算的对应素描纹理图片的权重为0 那么这时 对应颜色会为(0,0,0,0)
                fixed4 sketchColor0 = tex2D(_Sketch0, i.uv) * i.weights1.x;
                fixed4 sketchColor1 = tex2D(_Sketch1, i.uv) * i.weights1.y;
                fixed4 sketchColor2 = tex2D(_Sketch2, i.uv) * i.weights1.z;
                fixed4 sketchColor3 = tex2D(_Sketch3, i.uv) * i.weights2.x;
                fixed4 sketchColor4 = tex2D(_Sketch4, i.uv) * i.weights2.y;
                fixed4 sketchColor5 = tex2D(_Sketch5, i.uv) * i.weights2.z;

                //最亮的部分相关的计算 白色叠加
                fixed4 whiteColor = fixed4(1,1,1,1) * (1 - i.weights1.x - i.weights1.y - i.weights1.z 
                - i.weights2.x - i.weights2.y - i.weights2.z);

                fixed4 sketchColor = sketchColor0 + sketchColor1 + sketchColor2 + 
                sketchColor3 + sketchColor4 + sketchColor5 + whiteColor;

                UNITY_LIGHT_ATTENUATION(atten, i, i.wpos);

                return fixed4(sketchColor.rgb * atten * _Color.rgb, 1);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
