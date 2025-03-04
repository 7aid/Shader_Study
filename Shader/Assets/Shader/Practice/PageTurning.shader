Shader "MyShader/Practice/PageTurning"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _BackTex("BackTex", 2D) = "white" {}
        //翻页进度(0~180度)
        _AngleProgress("AngleProgress", Range(0, 180)) = 0
        //y轴弯曲程度(0~1) 
        _WeightY("WeightY", Range(0, 1)) = 0.5
        //x轴收缩程度(0~1)
        _WeightX("WeightX", Range(0, 1)) = 0.5
        //波长
        _WaveLength("WaveLength", Range(0, 3)) = 1
        //平移距离
        _MoveDis("MoveDis", float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Cull Off
        Pass
        {       
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _BackTex;
            float _AngleProgress;
            float _WeightY;
            float _WeightX;
            float _WaveLength;
            float _MoveDis;

            v2f vert (appdata_base v)
            {
                v2f o;
                float s;
                float c;
                //对顶点进行变换
                //先处理旋转
                //利用sincos函数 配合自定义参数 翻页的角度（进度）来得到对应
                //的sin和cos值
                sincos(radians(_AngleProgress),s,c);
                //构建Z轴旋转矩阵
                float4x4 rotationMul = {
                    c,-s,0,0,
                    s,c,0,0,
                    0,0,1,0,
                    0,0,0,1};
                //由于我们是基于Z轴旋转 所以我们将其按照x轴方向进行偏移
                v.vertex += float4(_MoveDis,0,0,0);
                //进行起伏处理
                float weight = 1 - abs(90 - _AngleProgress) / 90;
                //Y轴上下起伏
                v.vertex.y += sin(v.vertex.x * _WaveLength) * weight * _WeightY;
                //X轴收缩
                v.vertex.x -= v.vertex.x * weight * _WeightX;
                //平移后 再旋转
                float4 pos = mul(rotationMul, v.vertex);
                //再平移回来
                pos -= float4(_MoveDis,0,0,0);
                o.vertex = UnityObjectToClipPos(pos);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i, fixed face:VFACE) : SV_Target
            {             
                fixed4 col = face > 0 ? tex2D(_MainTex, i.uv) : tex2D(_BackTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
