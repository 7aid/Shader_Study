//�������ع����𶥵����
Shader "MyShader/Lambert_vert_half"
{
    Properties
    {
        //���ò�����ɫ
        _MainColor("_MainColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {"LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;

            struct v2f{
                fixed4 position:POSITION;
                fixed3 color:COLOR;
            };

            v2f vertex(appdata_base baseData){
                v2f data;
                data.position = UnityObjectToClipPos(baseData.vertex);
                fixed3 objNormal = UnityObjectToWorldNormal(baseData.normal);
                fixed3 lightNoraml = normalize(_WorldSpaceLightPos0.xyz);
                data.color = _MainColor * _LightColor0 * ( (dot(objNormal,lightNoraml) * 0.5 + 0.5 ) );
                data.color = data.color + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return data;
            }

            fixed4 fragment(v2f data) : SV_TARGET
            {
                // ��Ϊ�ǶԲ�͸�������崦�����Բ���Ҫ͸��
                return fixed4(data.color, 1);
            }
            ENDCG
        }
    }
}
