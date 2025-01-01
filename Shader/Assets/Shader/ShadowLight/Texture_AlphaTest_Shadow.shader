//透明测试阴影  透明阈值
Shader "MyShader/Texture_AlphaTest_Shadow"
{
    Properties
    {   //材质漫反射颜色
        _Color("Color",Color) = (1,1,1,1)
        //单张纹理信息
        _MainTex ("MainTex", 2D) = ""{}
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularNum("SpecularNum", Range(0,20)) = 5
        //透明度阈值
        _Cutoff("Cutoff", Range(0,1)) = 0.5
    }
    SubShader
    {
         //设置渲染队列顺序  设置投忽略投影器（半透明效果需要设置）   设置渲染类型标签值为透明切割
        Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
        Pass
        {
            
            Tags {"LightMode" = "ForwardBase"}

            Cull Off


            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                //裁剪空间坐标
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //我们可以单独的声明两个float2的成员用于记录 颜色和法线纹理的uv坐标
                //也可以直接声明一个float4的成员 xy用于记录颜色纹理的uv，zw用于记录法线纹理的uv
                float4 uv:TEXCOORD0;
                //世界空间法线
                fixed3 normal:NORMAL;
                //世界空间光线
                fixed3 dirLight:TEXCOORD1;
                //世界空间视角
                fixed3 dirView:TEXCOORD2;
                //世界空间视角
                fixed3 wpos:TEXCOORD3;
                SHADOW_COORDS(4)
            };
            //材质漫反射颜色
            float4 _Color;
            //纹理
            sampler2D _MainTex;
            //纹理的缩放和偏移
            float4 _MainTex_ST;
            //高光反射颜色
            fixed4 _SpecularColor;
            //高反光泽度
            float _SpecularNum;
            //透明度阈值
            fixed _Cutoff;

            v2f vert (appdata_base base)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(base.vertex);
               //主帖图uv坐标
                data.uv.xy = base.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                data.normal = UnityObjectToWorldNormal(base.normal);
                data.dirLight = normalize(WorldSpaceLightDir(base.vertex));
                data.dirView = normalize(WorldSpaceViewDir(base.vertex));
                data.wpos = mul(unity_ObjectToWorld, base.vertex);
                //坐标宏转换
                TRANSFER_SHADOW(data);

                return data;
            }

            fixed4 frag (v2f data) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, data.uv.xy);
                //进行阈值裁剪检测
				clip(texColor.a - _Cutoff);
                //纹理颜色需要和漫反射材质颜色进行叠加计算
                fixed3 albedo = texColor.rgb * _Color.rgb;
                //获取兰伯特漫反射光照颜色
                fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(normalize(data.normal), data.dirLight));
                //获取对角向量的标准化
                fixed3 halfDir = normalize(data.dirView + data.dirLight);
                //获取布林方高光反射颜色
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(data.normal, halfDir)), _SpecularNum);            
                //光照衰减计算
                UNITY_LIGHT_ATTENUATION(atten, data, data.wpos);
               
                //获取布林方光照模型
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + (lambertColor + specularColorBack) * atten;
                return fixed4(color, 1);
            }
            ENDCG
        }
    }
    Fallback "Transparent/Cutout/VertexLit"

}
