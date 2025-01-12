//2D河流（带阴影的）
Shader "MyShader/2DRiver"
{
    Properties
    {
        //主纹理
        _MainTex("MainTex", 2D) = "white" {}
        //叠加的颜色
        _Color("Color",Color) = (1,1,1,1)
        //波动幅度
        _WaveAmplitude("WaveAmplitude", float) = 1
        //波动频率
        _WaveFrequency("WaveFrequency", float) = 1
        //波长的倒数
        _InvWaveLength("InvWaveLength", float) = 1

        //纹理变化速度
        _Speed("Speed", float) = 1

    }
    SubShader
    {   //DisableBatching,是否对SubShader关闭批处理我们在制作顶点动画时，有时需要关闭该Shader的批处理,因为我们在制作顶点动画时，有时需要使用模型空间下的数据
        //而批处理会合并所有相关的模型，这些模型各自的模型空间会丢失，导致我们无法正确使用模型空间下相关数据,在实现流程的2D河流效果时，
        //我们就需要让顶点在模型空间下进行偏移因此我们需要使用该标签，为该Shader关闭批处理
        Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;

            float _Speed;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base o)
            {
                v2f data;
                //模型空间下的偏移位置
                float4 offset;             
                //让它在模型空间的x轴方向进行偏移 (因为此处模型空间下该顶点的流动控制是z轴，正常应该是x轴)
                offset.x = sin(_Time.y * _WaveFrequency + o.vertex.z * _InvWaveLength) * _WaveAmplitude;
                offset.yzw = float3(0,0,0);
                data.pos = UnityObjectToClipPos(o.vertex + offset);
                data.uv = o.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
                data.uv += float2(0, _Time.y * _Speed);
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float4 color = tex2D(_MainTex, i.uv);
                color.rgb *= _Color.rgb;
                return color;
            }
            ENDCG
        }
        //该注释主要用于进行阴影投影 主要是用来计算阴影映射纹理的
        Pass
        {
            Tags{"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //  该编译指令时告诉Unity编译器生成多个着色器变体
            //  用于支持不同类型的阴影（SM，SSSM等等）
            //  可以确保着色器能够在所有可能的阴影投射模式下正确渲染
            #pragma multi_compile_shadowcaster
              //  其中包含了关键的阴影计算相关的宏
            #include "UnityCG.cginc"

            float _WaveAmplitude;
            float _WaveFrequency;
            float _InvWaveLength;

            struct v2f
            {
                //顶点到片元着色器阴影投射结构体数据宏
                //这个宏定义了一些标准的成员变量
                //这些变量用于在阴影投射路径中传递顶点数据到片元着色器
                //我们主要在结构体中使用
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f data;
                //模型空间下的偏移位置
                float4 offset;             
                //让它在模型空间的x轴方向进行偏移 (因为此处模型空间下该顶点的流动控制是z轴，正常应该是x轴)
                offset.x = sin(_Time.y * _WaveFrequency + v.vertex.z * _InvWaveLength) * _WaveAmplitude;
                offset.yzw = float3(0,0,0);
                //需要进行顶点偏移位置的修改
                //直接在模型空间下顶点坐标进行计算即可
                v.vertex = v.vertex + offset;

                //转移阴影投射器法线偏移宏
                //用于在顶点着色器中计算和传递阴影投射所需的变量
                //主要做了
                //2-2-1.将对象空间的顶点位置转换为裁剪空间的位置
                //2-2-2.考虑法线偏移，以减轻阴影失真问题，尤其是在处理自阴影时
                //2-2-3.传递顶点的投影空间位置，用于后续的阴影计算
                //我们主要在顶点着色器中使用
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(data);
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                //阴影投射片元宏
                //将深度值写入到阴影映射纹理中
                //我们主要在片元着色器中使用
               SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }

    Fallback "VertexLit"
}
