//世界空间下 实现法线纹理shader
Shader "MyShader/Texture_Diffuse2"
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
        //高光反射颜色
        _SpecularColor("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecularNum("SpecularNum", Range(0,20)) = 5
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
                fixed4 pos:SV_POSITION;
                //float2 uvTex:TEXCOORD0;
                //float2 uvBump:TEXCOORD1;
                //我们可以单独的声明两个float2的成员用于记录 颜色和法线纹理的uv坐标
                //也可以直接声明一个float4的成员 xy用于记录颜色纹理的uv，zw用于记录法线纹理的uv
                fixed4 uv:TEXCOORD0;
                //世界空间坐标
                //fixed4 wPos:TEXCOORD1;
                //矩阵  切线空间到世界空间
                //float3x3 mulT2W:TEXCOORD2;
                //为了提高GPU处理效率将float3x3的矩阵修改为float4的矩阵，并用w来存wPos坐标
                float4 mulLine1:TEXCOORD2;
                float4 mulLine2:TEXCOORD3;
                float4 mulLine3:TEXCOORD4;

            };
            //材质漫反射颜色
            fixed4 _MainColor;
            //纹理
            sampler2D _MainTex;
            //纹理的缩放和偏移
            fixed4 _MainTex_ST;
            //法线纹理
            sampler2D _BumpTex;
            //法线纹理的缩放和偏移
            fixed4 _BumpTex_ST;
            //凹凸程度
            float _BumpNum;
            //高光反射颜色
            fixed4 _SpecularColor;
            //高反光泽度
            float _SpecularNum;

            v2f vert (appdata_full full)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(full.vertex);
                //主帖图uv坐标
                data.uv.xy = full.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //法线贴图uv坐标
                data.uv.zw = full.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
                //世界空间法线
                fixed3 wNormal = UnityObjectToWorldNormal(full.normal);
                //世界空间切线
                fixed3 wTangent = UnityObjectToWorldDir(full.tangent.xyz);
                //世界空间副切线
                fixed3 wbiTangent = cross(normalize(wTangent), normalize(wNormal)) * full.tangent.w;
                //矩阵  世界空间到切线空间的
                //float3x3 mulW2T = float3x3(full.tangent.xyz, biTangent, full.normal);
                fixed3 wPos = mul(unity_ObjectToWorld, full.vertex).xyz;
                //矩阵  切线空间到世界空间
                //float3x3 mulT2W = float3x3
                //(
                //float3(full.tangent.x, biTangent.x, full.normal.x),
                //float3(full.tangent.y, biTangent.y, full.normal.y),
                //float3(full.tangent.z, biTangent.z, full.normal.z)
                //);
                //data.mulT2W = mulT2W;
                data.mulLine1 = float4(wTangent.x, wbiTangent.x, wNormal.x, wPos.x);
                data.mulLine2 = float4(wTangent.y, wbiTangent.y, wNormal.y, wPos.y);
                data.mulLine3 = float4(wTangent.z, wbiTangent.z, wNormal.z, wPos.z);
                return data;

            }

            fixed4 frag (v2f data) : SV_Target
            {
                fixed3 color;
                //取出法线贴图的法线信息
                float4 packNormal = tex2D(_BumpTex, data.uv.zw);
                //由于法线XYZ分量范围在[-1，1]之间而像素RGB分量范围在[0，1]之间
                //normalTex = normalTex * 2 - 1;
                //也可以使用UnpackNormal方法对法线信息进行逆运算以及可能的解压 
                float3 tangentNormal = UnpackNormal(packNormal);
                //乘以BumpScale用于控制凹凸程度
                tangentNormal.xy *= _BumpNum;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                //世界空间贴图法线
                //fixed3 wTangentNormal = mul(data.mulT2W, tangentNormal);
                float3 wTangentNormal = float3(dot(data.mulLine1.xyz, tangentNormal), dot(data.mulLine2.xyz, tangentNormal),  dot(data.mulLine3.xyz, tangentNormal));
                //主贴图颜色和漫反射颜色叠加叠加
                fixed3 albedo = tex2D(_MainTex, data.uv.xy) * _MainColor.rgb;
                //世界空间坐标
                //fixed3 wPos = data.wPos;
                fixed3 wPos = fixed3(data.mulLine1.w, data.mulLine2.w, data.mulLine3.w);
                //标准化世界空间光源方向
                fixed3 dirLight = normalize(UnityWorldSpaceLightDir(wPos));
                //标准化世界空间视角方向
                fixed3 dirView = normalize(UnityWorldSpaceViewDir(wPos));
                //获取兰伯特漫反射光照颜色
                fixed3 lambertColor = _LightColor0.rgb * albedo * max(0, dot(wTangentNormal, dirLight));
                //获取对角向量的标准化
                float3 halfDir = normalize(dirLight + dirView);
                //获取布林方高光反射颜色
                fixed3 specularColorBack = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(wTangentNormal, halfDir)), _SpecularNum);
                //获取布林方光照模型
                color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + lambertColor + specularColorBack;
                return fixed4(color, 1);

            }
            ENDCG
        }
    }
}
