//素描
Shader "MyShader/Practice/Dissolve"
{
    Properties
    {
        //整体颜色叠加
        _MainColor("MainColor", Color) = (1,1,1,1)
        _MainTex("MainTex", 2D) = ""{}
        _BumpMap("BumpMap", 2D) = ""{}
        _BumpScale("BumpScale", Range(0, 1)) = 1
        _SpecualrColor("SpecularColor", Color) = (1,1,1,1)
        _SpecualrNum("SpecualrNum", Range(8,256)) = 18

        //噪声纹理
        _Noise("Noise", 2D) = ""{}
        //渐变纹理
        _Gradient("Gradient", 2D) = ""{}
        //消融进度
        _Dissolve("Dissolve", Range(0, 1)) = 0
        //边缘范围
        _Range("Range", Range(0, 1)) = 0
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;

                float4 uv : TEXCOORD0;
                //噪声纹理uv 用于之后计算偏移缩放
                float2 uvnoise : TEXCOORD1;
                //光的方向 相对于切线空间下的
                float3 lightDir : TEXCOORD2;
                //视角的方向 相对于切线空间下的
                float3 viewDir : TEXCOORD3;
                float3 wpos : TEXCOORD4;
                SHADOW_COORDS(5)
            };
           
            fixed4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _SpecualrColor;
            fixed _SpecualrNum;

            sampler2D _Noise;
            float4 _Noise_ST;
            sampler2D _Gradient;
            float _Dissolve;
            float _Range;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                //计算噪声的缩放偏移
                o.uvnoise = v.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;
                //模型空间到切线空间的 转换矩阵(计算副切线 计算叉乘结果后 垂直与切线和法线的向量有两条 通过乘以 切线当中的w，就可以确定是哪一条)
                float3 binormal = cross(normalize(v.tangent), normalize(v.normal)) * v.tangent.w;
                //转换矩阵
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                o.lightDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 noiseColor = tex2D(_Noise, i.uvnoise.xy).rgb;
                clip(_Dissolve == 1 ? -1 : noiseColor.r - _Dissolve);

                //通过纹理采样函数 取出法线纹理贴图中的数据
                float4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                //取出来的法线数据 进行逆运算并且可能会进行解压缩的运算，最终得到切线空间下的法线数据
                float3 tangentNormal = UnpackNormal(packedNormal);
                //乘以凹凸程度的系数
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                //颜色纹理和漫反射颜色叠加
                fixed3 abledo = tex2D(_MainTex, i.uv.xy) * _MainColor.rgb;
                //兰伯特
                fixed3 lamberColor = _LightColor0.rgb * abledo.rgb * max(0, dot(tangentNormal, normalize(i.lightDir)));
                //半角向量
                float3 halfA = normalize(normalize(i.viewDir) + normalize(i.lightDir));
                //高光反射
                fixed3 specularColor = _LightColor0.rgb * _SpecualrColor.rgb * pow(max(0, dot(tangentNormal, halfA)), _SpecualrNum);
                //阴影接受强度计算
                UNITY_LIGHT_ATTENUATION(atten, i, i.wpos);
                //布林方
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * abledo + lamberColor * atten + specularColor;

                //处理原本颜色和消融颜色选择
                fixed value = 1 - smoothstep(0, _Range, noiseColor.r - _Dissolve);
                fixed3 gradientColor = tex2D(_Gradient, fixed2(value, 0.5)).rgb;
                //最终颜色
                //当消融进度为0时必须要让颜色使用模型本来的颜色
                //在这里使用step(0.000001, _Dissolve)的原因是，如果当_Dissolve是0时
                //可能value还会有很小的值导致没消融干净，所以使用该函数确认当消融进度是0时，
                //整个模型正确渲染
                fixed3 finalColor = lerp(color, gradientColor, value * step(0.000001, _Dissolve));
                return fixed4(finalColor.rgb, 1);
            }
            ENDCG
        }

        //该Pass主要进行阴影投射和消融
        Pass
        {
            Tags{"LightMode"="ShadowCaster"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //  该编译指令时告诉Unity编译器生成多个着色器变体
            //  用于支持不同类型的阴影（SM，SSSM等等）
            //  可以确保着色器能够在所有可能的阴影投射模式下正确渲染
            #pragma multi_compile_fwdbase
            // 包含了关键的阴影计算相关宏
            #include "UnityCG.cginc"

            struct v2f
            {
               //噪声纹理uv 用于之后计算偏移缩放
                float2 uvnoise:TEXCOORD0;
                //顶点到片元着色器阴影投射结构体数据宏
                //这个宏定义了一些标准的成员变量
                //这些变量用于在阴影投射路径中传递顶点数据到片元着色器
                //我们主要在结构体中使用
                V2F_SHADOW_CASTER;
            };

            sampler2D _Noise;//噪声纹理
            float4 _Noise_ST;
            fixed _Dissolve;

            v2f vert(appdata_base v)
            {
                v2f o;
                 //计算噪声纹理的缩放偏移
                o.uvnoise = v.texcoord.xy * _Noise_ST.xy + _Noise_ST.zw;

                //转移阴影投射器法线偏移宏
                //用于在顶点着色器中计算和传递阴影投射所需的变量
                //主要做了
                //2-2-1.将对象空间的顶点位置转换为裁剪空间的位置
                //2-2-2.考虑法线偏移，以减轻阴影失真问题，尤其是在处理自阴影时
                //2-2-3.传递顶点的投影空间位置，用于后续的阴影计算
                //我们主要在顶点着色器中使用
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i):SV_Target
            {
                //剔除-消融
                fixed3 noiseColor = tex2D(_Noise, i.uvnoise.xy).rgb;
                clip(_Dissolve == 1 ? -1 : noiseColor.r - _Dissolve);
                 //阴影投射片元宏
                //将深度值写入到阴影映射纹理中
                //我们主要在片元着色器中使用
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
