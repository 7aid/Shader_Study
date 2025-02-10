Shader "MyShader/Practice/ObjectCutting"
{
    Properties
    {
        //正面纹理
        _MainTex ("Texture", 2D) = "white" {}
        //背面纹理
        _BackTex("BackTexture",2D) = "white" {}
        //切割方向 0：x   1：y   2：z
       [KeywordEnum(X, Y ,Z)]_CuttingDir("CuttingDir",float) = 0
        //切割方向翻转
       [KeywordEnum(No, Yes)] _Invert("Invert",float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        //关闭剔除 因为正反两面都要渲染
        Cull Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //让VFACE兼容性更好 
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 wpos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BackTex;
            float _CuttingDir;
            float _Invert;
            float4 _CuttingPos;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.wpos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i, fixed face:VFACE) : SV_Target
            {
                //通过用face来进行正反面判断 Unity Shader 因为有了语义 会自动传入对应的参数
                fixed4 col = face > 0 ? tex2D(_MainTex, i.uv) : tex2D(_BackTex, i.uv);
                //丢弃中间值
                fixed value;
				if (_CuttingDir==0) 
                  value = step(_CuttingPos.x, i.wpos.x) ;
                else if (_CuttingDir==1)
                  value = step(_CuttingPos.y, i.wpos.y) ;
                else if (_CuttingDir==2)
                  value = step(_CuttingPos.z, i.wpos.z) ;
                //是否进行翻转切割
                value = _Invert == 1 ? 1 - value : value;
				if (value == 0) 
                //传入-1（小于0） 代表这个片元不会渲染 直接丢弃
                  clip(-1);             
                return col;
            }
            ENDCG
        }
    }
}
