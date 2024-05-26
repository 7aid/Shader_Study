Shader "MyShader/Texture_Model_BlinnPhong"
{
    Properties
    {
        //纹理贴图
        _MainTex ("Texture", 2D) = "" {}
        //漫反射光颜色
        _MainColor ("MainColor", Color) = (1,1,1,1)
        //高光反射颜色
        _SpecularColor ("SpecularColor", Color) = (1,1,1,1)
        //光泽度
        _SpecGloss ("SpecGloss", Range(0, 20)) = 0.5  
    }
    SubShader
    {
        Tags{"LightMode" = "ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            //纹理贴图颜色
            sampler2D _MainTex;
            //纹理贴图缩放和偏移
            float4 _MainTex_ST;
            //漫反射颜色
            fixed4 _MainColor;
            //高光反射颜色
            fixed4 _SpecularColor;
            //光泽度
            fixed _SpecGloss;
            
            //获取兰伯特漫反射
            fixed3 getLambertColor(fixed3 wNormal, fixed3 albedo)
            {
                fixed3 color;
                fixed3 dirLight = normalize(_WorldSpaceLightPos0);
                color = _LightColor0.rgb * albedo * max(0, dot(wNormal, dirLight));
                return color;
            }
            //获取布林高光反射颜色
            fixed3 getSpecColor(fixed3 wNormal, fixed3 wPos)
            {
                fixed3 color;
                //半角向量 = 视角单位向量 + 光源单位向量
                fixed3 dirHalf = normalize(_WorldSpaceCameraPos.xyz - wPos) + normalize(_WorldSpaceLightPos0);
                color = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(wNormal, normalize(dirHalf))), _SpecGloss);
                return color;
            }

            struct v2f
            {
                //裁剪空间坐标
                fixed4 pos:SV_POSITION;
                //纹理信息
                fixed2 uv:TEXCOORD0;
                //世界法线
                fixed3 wNormal:NORMAL;
                //世界坐标
                fixed3 wPos:TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(v.vertex);
                data.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.wz;
                //data.uv = TRANSFORM_UV(v.texcoord.xy, _MainTex);
                data.wNormal = UnityObjectToWorldNormal(v.normal);
                data.wPos = mul(unity_ObjectToWorld, v.vertex);
                return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               //在此处传入的uv是经过插值运算后的 每一个片元都有自己的一个uv坐标
               //这样才会精准的在贴图当中取出颜色
               //纹理颜色需要和漫反射材质颜色进行叠加共同决定最终的颜色
               fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _MainColor.rgb;
               fixed3 lambertColor = getLambertColor(i.wNormal, albedo);
               fixed3 specColor = getSpecColor(i.wNormal, i.wPos);
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo + lambertColor + specColor;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
