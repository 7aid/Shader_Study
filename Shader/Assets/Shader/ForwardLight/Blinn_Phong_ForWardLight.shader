Shader "MyShader/Blinn_Phong_ForWardLight/Blinn_Phong_ForwardLight"
{
    Properties
    {
        //材质漫反射颜色
        _MainColor("_MainColor", Color) = (1,1,1,1)
        //高光反射颜色
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularGloss("_SpecularGloss",Range(0, 255)) = 15
    }
    SubShader
    {
        //Base Pass 基础渲染通道（渲染物体的主要光照通道，用于处理主要的光照效果，主要用于计算逐像素的平行光以及所有逐顶点和SH光源，可实现的效果：漫反射，高光反射，自发光，阴影，光照纹理等）
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //用于帮助我们编译所有变体 并且保证衰减相关光照变量能够正确赋值到对应的内置变量中
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //世界空间法线
               fixed3 wnormal:NORMAL;
               //裁剪空间顶点
               fixed4 pos:SV_POSITION;
               //世界空间顶点
               fixed3 wpos:TEXCOORD;
            };
            //获取兰伯特漫反射颜色
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;     
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //获取Phone高光反射颜色
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //对角向量
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - wpos);
               //标准化对角向量
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }
            fixed4 frag (v2f i) : SV_Target
            {
               //兰伯特漫反射
               fixed3 lambertColor = getLambertColor(i.wnormal);
               //布林方高光反射
               fixed3 phongSpecular = getBlinnPhoneSpecularColor(i.wnormal, i.wpos);
               //衰减光
               fixed atten = 1;
               //光的衰减需要和平行光，高光反射进行乘法计算
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + (lambertColor + phongSpecular) * atten;
               return fixed4(color, 1);
            }
            ENDCG
        }
        //Additional Pass 附加渲染通道（渲染物体的额外的光照通道，用于处理一些附加的光照效果，主要用于计算其它影响物体的逐像素光源，每个光源都会执行一次该Pass，可实现的效果：描边，轮廓，辉光等）
        Pass
        {
            //附加通道
            Tags{"LightMode" = "ForwardAdd"}
            //用于和其它光源颜色进行混合计算
            Blend One One 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //该指令保证我们在附加渲染通道中能访问到正确的光照变量并且会帮助我们编译Additional Pass中所有变体
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //世界空间法线
               fixed3 wnormal:NORMAL;
               //裁剪空间顶点
               fixed4 pos:SV_POSITION;
               //世界空间顶点
               fixed3 wpos:TEXCOORD;
            };
            //获取兰伯特漫反射颜色
            fixed3 getLambertColor(fixed3 wnormal, fixed3 wLightDir)
            {
                fixed3 color;     
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, wLightDir));
                return color;
            }
            //获取Phone高光反射颜色
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos, fixed3 wLightDir)
            {           
               fixed3 color; 
               //对角向量
               fixed3 dirHalf = wLightDir + normalize(_WorldSpaceCameraPos - wpos);
               //标准化对角向量
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {                   
               //获取兰伯特漫反射和布林方高光
               #if defined(_DIRECTIONAL_LIGHT)
               //平行光directional
               fixed3 wLightDir = normalize(_WorldSpaceLightPos0);
               #else
               //点光源和聚光灯的方向是光坐标-物体坐标
               fixed3 wLightDir = normalize(_WorldSpaceLightPos0 - i.wpos);
               #endif
               fixed3 lambertColor = getLambertColor(i.wnormal, wLightDir);
               //布林方高光反射
               fixed3 phongSpecularColor = getBlinnPhoneSpecularColor(i.wnormal, i.wpos, wLightDir);

               //获取光的衰减和光的遮罩
               //兰伯特漫反射
               #if defined(_DIRECTIONAL_LIGHT)
               //平行光没有衰减信息
               fixed atten = 1;
               #elif defined(_POINT_LIGHT)
               //点光源
               //将顶点从世界空间转换到光源空间
               fixed3 lightCoord = mul(unity_WorldToLight, float4(i.wpos, 1));
               //在CG中没有bool值 只有0和1来代表false和true，所以此处的lightCoord.z > 0来判断顶点在光的前方还是后方
               //后方表示没有受到光的衰减
               fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
               #elif defined(_SPOT_LIGHT)
               //聚光灯
                //将顶点从世界空间转换到光源空间,保留w是聚光灯需要w取出遮罩衰减信息
               fixed4 lightCoord = mul(unity_WorldToLight, float4(i.wpos, 1));
               //聚光灯衰减是在_LightTextureB0里获取的，遮罩衰减是在_LightTexture0获取
               fixed atten = (lightCoord.z > 0) 
               //需要将各个横截面映射到最大的面上进行采用, 需要将uv坐标映射到0~1的范围再从纹理中采用，
               //lightCoord.xy / lightCoord.w 进行缩放后x，y的取值范围是-0.5~0.5之间，加上0.5转换至0~1
               * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w;
               * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
               #else
               //其它逻辑
               fixed atten = 1;
               #endif
   
               //因为在Base Pass算过一次环境光，所以此处不需要再算一次
               fixed3 color = (lambertColor + phongSpecularColor) * atten;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
