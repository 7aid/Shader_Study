Shader "MyShader/SequenceFrame"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}

        //行列数
        _CellRow("CellRow", Float) = 8
        _CellColumn("CellColumn", Float) = 8

        //动画切换播放速度
        _Speed("Speed", Float) = 50

    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _CellRow;
            float _CellColumn;
            float _Speed;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base o)
            {
                v2f data;
                data.pos = UnityObjectToClipPos(o.vertex);
                data.uv = o.texcoord.xy;
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                //得到当前帧 利用时间变量计算
                fixed frameIndex = floor(_Time.y * _Speed) % (_CellRow * _CellColumn);
                 //小格子（小图片）采样时的起始位置计算
                //除以对应的行和列 目的是将行列值 转换到 0~1的坐标范围内
                //1 - (floor(frameIndex / _Columns) + 1)/_Rows
                //  +1 是因为把格子左上角转换为格子左下角
                //  1- 因为UV坐标采样时从左下角进行采样的
                float2 frameuv = float2(frameIndex % _CellColumn / _CellColumn, 1 - (floor(frameIndex / _CellRow) + 1) /_CellRow);
                //得到uv缩放比例 相当于从0~1大图 隐射到一个 0~1/n的一个小图中
				float2 size = float2(1 / _CellColumn, 1 / _CellRow); 
                 //计算最终的uv采样坐标信息
                //*size 相当于把0~1范围 缩放到了 0~1/8范围
                //+frameUV 相当于把起始的采样位置 移动到了 对应帧小格子的起始位置
                float2 uv = i.uv * size + frameuv;
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
