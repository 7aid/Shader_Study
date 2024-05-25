//兰伯特光照逐顶点光照
Shader "MyShader/Lambort_vert"
{
    Properties
    {
        //材质的漫反射属性
        _LambortColor("_LambortColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        //渲染标签，表示不透明物体向前渲染
        Tags{"LightMode" = "ForwardBase"}
        //渲染通道
        Pass
        {
            CGPROGRAM
            //顶点着色器编译指令
            #pragma vertex vert
            //片元着色器编译质量
            #pragma fragment frag
            //引用对应的内置文件 
            //主要是为了之后 的 比如内置结构体使用，内置变量使用
            #include "UnityCG.cginc"          
            #include "Lighting.cginc"

            fixed4 _LambortColor;
           
            //顶点着色器传递给片元着色器的内容
            struct v2f
            {
                ////裁剪空间下的顶点坐标信息
                float4 pos:SV_POSITION;
                //对应顶点的漫反射光照颜色
                fixed3 color:COLOR;
            };

            //逐顶点光照 所以相关的漫反射光照颜色的计算 需要写在顶点着色器 回调函数中
            v2f vert(appdata_base data)
            {
                v2f v2f;
                //将模型空间的点转换至裁剪空间
                v2f.pos = UnityObjectToClipPos(data.vertex);
                //获取模型空间点在世界空间点的标准化法线
                fixed3 dataNormal = UnityObjectToWorldNormal(data.normal);
                //获取世界空间光源标准化向量
                fixed3 lightNomralizeDir = normalize(_WorldSpaceLightPos0.xyz);
                //获取世界空间光源在模型空间点的颜色         
                v2f.color = _LightColor0.rgb * _LambortColor.rgb * max(0, dot(lightNomralizeDir, dataNormal));
                //兰伯特光照模型环境光变量，模拟光对物体阴影的影响，避免物体被光照射不到的地方完全黑暗
                v2f.color = v2f.color + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return v2f;
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                //在此处返回漫反射光照颜色(透明值默认为1)
                return fixed4(v2f.color.rgb, 1);
            }
            ENDCG    
        }
    }
}



