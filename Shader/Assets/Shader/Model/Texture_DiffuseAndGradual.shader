//布林方渐变纹理与法线贴图纹理Shader --- 切线空间实现
Shader "MyShader/Model/Texture_DiffuseAndGradual"
{
    Properties
    {   //材质漫反射颜色
        _MainColor("MainColor",Color) = (1,1,1,1)
        //单张纹理信息
        _MainTex ("MainTex", 2D) = ""{}
        //法线纹理信息
        _BumpTex("BumpTex", 2D) = ""{}
        //凹凸程度
        _BumpNum("BumpNum", Range(0,2)) = 1
        //渐变纹理贴图
        _GradualTex("GradualTex", 2D) = ""{}
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularNum("SpecularNum", Range(8, 255)) = 20
    }
    SubShader
    {
        Pass
        {   //设置光渲染方式，不透明物体使用向前渲染
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                //裁剪空间坐标
                float4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //我们可以单独的声明两个float2的成员用于记录 颜色和法线纹理的uv坐标
                //也可以直接声明一个float4的成员 xy用于记录颜色纹理的uv，zw用于记录法线纹理的uv
                float4 uv:TEXCOORD0;
                //切线空间下光的方向
                float3 lightDir:TEXCOORD1;
                //切线空间下视角方向
                float3 viewDir:TEXCOORD2;
            };
            //材质漫反射颜色
            float4 _MainColor;
            //纹理
            sampler2D _MainTex;
            //纹理的缩放和偏移
            float4 _MainTex_ST;
            //法线纹理
            sampler2D _BumpTex;
            //法线纹理的缩放和偏移
            float4 _BumpTex_ST;
            //凹凸程度
            float _BumpNum;
            //高光反射颜色
            fixed4 _SpecularColor;
            //高反光泽度
            float _SpecularNum;
            //渐变纹理
            sampler2D _GradualTex;
            float4 _GradualTex_ST;

            v2f vert (appdata_full full)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(full.vertex);
                //主帖图uv坐标
                data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //法线贴图uv坐标
                data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //副切线
                fixed3 biTangent = cross(normalize(full.tangent), normalize(full.normal)) * full.tangent.w;
                //矩阵
                float3x3 mulM2T = float3x3(
                        full.tangent.xyz,
                        biTangent, 
                        full.normal
                );
                //切线空间光照方向
                data.lightDir = mul(mulM2T, ObjSpaceLightDir(full.vertex));
                 //切线空间视角方向
                data.viewDir = mul(mulM2T, ObjSpaceViewDir(full.vertex));

                return data;

            }

            fixed4 frag (v2f data) : SV_Target
            {
                //取出法线贴图的法线信息
                float4 packNormal = tex2D(_BumpTex, data.uv.zw);
                //由于法线XYZ分量范围在[-1，1]之间而像素RGB分量范围在[0，1]之间
                //normalTex = normalTex * 2 - 1;
                //也可以使用UnpackNormal方法对法线信息进行逆运算以及可能的解压 
                float3 tangentNormal = UnpackNormal(packNormal);
                //乘以BumpScale用于控制凹凸程度
                tangentNormal.xy *= _BumpNum;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //主贴图颜色和漫反射颜色叠加叠加
                fixed3 albedo = tex2D(_MainTex, data.uv.xy) * _MainColor.rgb;
                //获取半兰伯特漫反射余弦
                fixed halfLambertNum = dot(normalize(tangentNormal) , normalize(data.lightDir)) * 0.5 + 0.5;
                //获取漫反射颜色
                fixed3 diffuseColor = _LightColor0.rgb * albedo.rgb * tex2D(_GradualTex, fixed2(halfLambertNum, halfLambertNum)).rgb;
                //获取对角向量的标准化
                float3 halfDir = normalize( normalize(data.viewDir) + normalize(data.lightDir));
                //获取布林方高光反射颜色
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(tangentNormal, halfDir)), _SpecularNum);
                //获取布林方光照模型
                fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + diffuseColor + specularColorBack;
                return fixed4(color.rgb, 1);

            }
            ENDCG
        }
    }
}
