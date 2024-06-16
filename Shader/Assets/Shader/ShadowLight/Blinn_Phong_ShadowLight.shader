Shader "MyShader/Blinn_Phong_ShadowLight"
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
            //用于得到阴影接收的3个宏
            #include "AutoLight.cginc"

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
               //该宏在v2f结构体（顶点着色器返回值）中使用，本质上就是声明了一个用于对阴影纹理进行采样的坐标，
               //在内部实际上就是声明了一个名为_ShadowCoord的阴影纹理坐标变量，               
               //需要注意的是：在使用时 SHADOW_COORDS(2) 传入参数2，表示需要时下一个可用的插值寄存器的索引值   
               SHADOW_COORDS(2)
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
               // 该宏在顶点着色器函数中调用，传入对应的v2f结构体对象，该宏会在内部自己判断应该使用哪种阴影映射技术（SM、SSSM），
               // 最终的目的就是将顶点进行坐标转换并存储到_ShadowCoord阴影纹理坐标变量中，需要注意的是：
               //1.该宏会在内部使用顶点着色器中传入的结构体，该结构体中顶点的命名必须是vertex
               //2.该宏会在内部使用顶点着色器的返回结构体，  其中的顶点位置命名必须是pos
               TRANSFER_SHADOW(data);
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
               //该宏在片元着色器中调用，传入对应的v2f结构体对象，该宏会在内部利用v2f中的 阴影纹理坐标变量(ShadowCoord)对相关纹理进行采样，
               //将采样得到的深度值进行比较，以计算出一个fixed3的阴影衰减值，我们只需要使用它返回的结果和 (漫反射+高光反射) 的结果相乘即可
               fixed3 shadow = SHADOW_ATTENUATION(i);
               //光的衰减需要和平行光，高光反射进行乘法计算
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + (lambertColor + phongSpecular) * atten * shadow;
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
        //这个Pass主要用于进行阴影投影 主要是用来计算阴影映射纹理的,另外一种方法是使用Fallback "Specluar"
        //Pass
        //{
        //    //设置渲染标签
        //    Tags{"LightMode" = "ShadowCaster"}
            
        //    CGPROGRAM
        //    //设置编译指令告诉Unity编译器生成多个着色器变体，用于支持不同类型的阴影（SM，SSSM等等），可以确保着色器能够在所有可能的阴影投射模式下正确渲染
        //    #pragma multi_compile_shadowcaster

        //    #pragma vertex vert
        //    #pragma fragment frag
        //    #include "UnityCG.cginc"
        //    struct v2f 
        //    {
        //        //顶点到片元着色器阴影投射结构体数据宏，这个宏定义了一些标准的成员变量，这些变量用于在阴影投射路径中传递顶点数据到片元着色器，我们主要在结构体中使用
        //        V2F_SHADOW_CASTER;
        //    };

        //    v2f vert(appdata_base v)
        //    {
        //        v2f data;
        //        //转移阴影投射器法线偏移宏，用于在顶点着色器中计算和传递阴影投射所需的变量，主要做了
        //        //2-2-1.将对象空间的顶点位置转换为裁剪空间的位置
        //        //2-2-2.考虑法线偏移，以减轻阴影失真问题，尤其是在处理自阴影时
        //        //2-2-3.传递顶点的投影空间位置，用于后续的阴影计算，我们主要在顶点着色器中使用
        //        TRANSFER_SHADOW_CASTER_NORMALOFFSET(data);
        //        return data;
        //    }

        //    fixed4 frag(v2f i):SV_Target
        //    {
        //        SHADOW_CASTER_FRAGMENT(i);
        //    }
        //    ENDCG
        //}
    }
            Fallback "Specular"
}
