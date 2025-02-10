//全息/垂直广告牌
Shader "MyShader/DynamicEffect/BillBoarding"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        //0为垂直广告牌  1为全向广告牌
        _State("State", Range(0,1)) = 1
    }
    SubShader
    {
        Tags {"RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}

        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _State;

            struct v2f
            {
                float4 pos:SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(appdata_base o)
            {
                v2f data;
                 //新坐标系的中心点（默认我们还是使用的模型空间原定）
                float3 centerPos = float3(0,0,0);
                //计算Z轴（normal）
                float3 viewObjPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                //得到Z轴对应的向量
                float3 forwardDir = viewObjPos - centerPos;
                //相当于把y往下压，如果_VerticalBillboarding是0 就代表把我们Z轴压到了xz平面 如果是1 那么就是正常的视角方向
                forwardDir.y *= _State;
                //单位化Z轴
                forwardDir = normalize(forwardDir);
                //模型空间下的Y轴正方向 作为它的 old up
                //为了避免z轴和010重合 ，因为重合后再计算叉乘 可能会得到0向量
                float3 upDir =  forwardDir.y > 0.999 ? float3(0,0,1) : float3(0,1,0);
                //利用叉乘计算X轴（right）
                float3 rightDir = normalize(cross(forwardDir, upDir));
                //去计算我们的Y轴 也就是newup
                float3 newUpDir = normalize(cross(forwardDir, rightDir));
                //得到顶点相对于新坐标系中心点的偏移位置
                float3 centerOffset = o.vertex.xyz - centerPos;
                //利用3个轴向进行最终的顶点位置的计算
                float3 newVertex = centerPos + centerOffset.x * rightDir + centerOffset.y * newUpDir + centerOffset.z * forwardDir;
                //把新顶点转换到裁剪空间
                data.pos = UnityObjectToClipPos(float4(newVertex, 1));
                 //uv坐标偏移缩放
                data.uv = o.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return data;
            }

            float4 frag(v2f i):SV_TARGET
            {
                fixed4 color = tex2D(_MainTex, i.uv);;
                color.rgb *= _Color.rgb;
                return  color;
            }
            ENDCG
        }
    }
}
