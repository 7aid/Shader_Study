//漫反射折射光照阴影
Shader "MyShader/CubeLambortRefract"
{
    Properties
    {
        //折射率A/B
        _Refractive("Refractive", Range(0.1,1)) = 0.7
        //立方体纹理
        _Cube("CubeMap", Cube) = ""{}
        //折射程度
        _RefractAmount("RefractAmount", Range(0,1)) = 1
        //漫反射颜色
        _LambertColor("LambertColor", Color) = (1,1,1,1)
        //折射颜色
        _RefractColor("RefractColor", Color) = (1,1,1,1)
    }
  
    SubShader
    {
      Tags {"RenderType" = "Opaque" "Queue" ="Geometry"}
      
      Pass 
      {
        Tags {"LightModel" = "ForwardBase"}

        CGPROGRAM

        #pragma vertex vert
        #pragma fragment frag
        #pragma multi_compile_fwdBase

        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        float _Refractive;
        samplerCUBE _Cube;
        float _RefractAmount;
        fixed4 _LambertColor;
        fixed4 _RefractColor;

        struct v2f 
        {
            float4 pos:SV_POSITION;//裁剪空间下顶点坐标
            //世界空间下反射向量，我们将把反射向量的计算放在顶点着色器函数中  
            //节约性能 表现效果也不会太差，肉眼几乎分辨不出来
            float3 worldRefrect:TEXCOORD0;

            fixed3 wPos:TEXCOORD1;

            fixed3 wNormal:NORMAL;

            SHADOW_COORDS(2)
        };

        v2f vert(appdata_base v)
        {
            v2f data;
            //顶点坐标转换
            data.pos = UnityObjectToClipPos(v.vertex);
            //计算反射方向向量
            //1.计算世界下空间法线向量
            data.wNormal = UnityObjectToWorldNormal(v.normal);
            //2.世界空间下顶点坐标
            data.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            //3.计算视角方向 内部是用摄像机位置 - 世界坐标位置
            fixed3 wViewDir = UnityWorldSpaceViewDir(data.wPos);
            //4.计算反射向量
            data.worldRefrect = refract(-normalize(wViewDir), normalize(data.wNormal), _Refractive);

            TRANSFER_SHADOW(data);
            return data;
        }

        fixed4 frag(v2f i):SV_TARGET
        {
            //对立方体纹理利用对应的反射向量进行采样
            fixed3 wLightDir = UnityWorldSpaceLightDir(i.wPos);
            fixed3 diffuseColor = _LightColor0.rgb * _LambertColor.rgb * max(0, dot(normalize(i.wNormal), normalize(wLightDir)));
        
            fixed3 cubemapColor = texCUBE(_Cube, i.worldRefrect).rgb * _RefractColor.rgb;

            UNITY_LIGHT_ATTENUATION(atten, i, i.wPos);
            //用采样颜色*采样率 决定最终的颜色
            fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + lerp(diffuseColor, cubemapColor, _RefractAmount) * atten;
            return fixed4(color, 1.0);
        }

        ENDCG
      }

    }  
    Fallback "Reflective/VertexLit"
}
