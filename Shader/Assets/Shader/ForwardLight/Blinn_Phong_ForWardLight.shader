Shader "MyShader/Blinn_Phong_ForwardLight"
{
    Properties
    {
        //������������ɫ
        _MainColor("_MainColor", Color) = (1,1,1,1)
        //�߹ⷴ����ɫ
        _SpecularColor("_SpecularColor", Color) = (1,1,1,1)
        //�����
        _SpecularGloss("_SpecularGloss",Range(0, 255)) = 15
    }
    SubShader
    {
        //Base Pass ������Ⱦͨ������Ⱦ�������Ҫ����ͨ�������ڴ�����Ҫ�Ĺ���Ч������Ҫ���ڼ��������ص�ƽ�й��Լ������𶥵��SH��Դ����ʵ�ֵ�Ч���������䣬�߹ⷴ�䣬�Է��⣬��Ӱ����������ȣ�
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //���ڰ������Ǳ������б��� ���ұ�֤˥����ع��ձ����ܹ���ȷ��ֵ����Ӧ�����ñ�����
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //����ռ䷨��
               fixed3 wnormal:NORMAL;
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
               //����ռ䶥��
               fixed3 wpos:TEXCOORD;
            };
            //��ȡ��������������ɫ
            fixed3 getLambertColor(fixed3 wnormal)
            {
                fixed3 color;     
                fixed3 dirLight = normalize(_WorldSpaceLightPos0.xyz);
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, dirLight));
                return color;
            }
            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos)
            {           
               fixed3 color; 
               //�Խ�����
               fixed3 dirHalf = normalize(_WorldSpaceLightPos0) + normalize(_WorldSpaceCameraPos - wpos);
               //��׼���Խ�����
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }
            fixed4 frag (v2f i) : SV_Target
            {
               //������������
               fixed3 lambertColor = getLambertColor(i.wnormal);
               //���ַ��߹ⷴ��
               fixed3 phongSpecular = getBlinnPhoneSpecularColor(i.wnormal, i.wpos);
               //˥����
               fixed atten = 1;
               //���˥����Ҫ��ƽ�й⣬�߹ⷴ����г˷�����
               fixed3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + (lambertColor + phongSpecular) * atten;
               return fixed4(color, 1);
            }
            ENDCG
        }
        //Additional Pass ������Ⱦͨ������Ⱦ����Ķ���Ĺ���ͨ�������ڴ���һЩ���ӵĹ���Ч������Ҫ���ڼ�������Ӱ������������ع�Դ��ÿ����Դ����ִ��һ�θ�Pass����ʵ�ֵ�Ч������ߣ��������Թ�ȣ�
        Pass
        {
            //����ͨ��
            Tags{"LightMode" = "ForwardAdd"}
            //���ں�������Դ��ɫ���л�ϼ���
            Blend One One 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //��ָ�֤�����ڸ�����Ⱦͨ�����ܷ��ʵ���ȷ�Ĺ��ձ������һ�������Ǳ���Additional Pass�����б���
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _MainColor;
            fixed4 _SpecularColor;
            fixed _SpecularGloss;
            struct v2f
            {
               //����ռ䷨��
               fixed3 wnormal:NORMAL;
               //�ü��ռ䶥��
               fixed4 pos:SV_POSITION;
               //����ռ䶥��
               fixed3 wpos:TEXCOORD;
            };
            //��ȡ��������������ɫ
            fixed3 getLambertColor(fixed3 wnormal, fixed3 wLightDir)
            {
                fixed3 color;     
                color = _LightColor0.rgb * _MainColor.rgb * max(0, dot(wnormal, wLightDir));
                return color;
            }
            //��ȡPhone�߹ⷴ����ɫ
            fixed3 getBlinnPhoneSpecularColor(fixed3 wnormal, fixed3 wpos, fixed3 wLightDir)
            {           
               fixed3 color; 
               //�Խ�����
               fixed3 dirHalf = wLightDir + normalize(_WorldSpaceCameraPos - wpos);
               //��׼���Խ�����
               fixed3 dirHalfNormalize = normalize(dirHalf);
               color = _LightColor0.rgb * _SpecularColor.rgb * ( pow( max( 0, dot( dirHalfNormalize, wnormal)), _SpecularGloss));
               return color;
            }

            v2f vert (appdata_base dataBase)
            {
               v2f data;
               data.pos = UnityObjectToClipPos(dataBase.vertex);
               data.wnormal = UnityObjectToWorldNormal(dataBase.normal);
               data.wpos = mul(unity_ObjectToWorld, dataBase.vertex);
               return data;
            }

            fixed4 frag (v2f i) : SV_Target
            {                   
               //��ȡ������������Ͳ��ַ��߹�
               #if defined(_DIRECTIONAL_LIGHT)
               //ƽ�й�directional
               fixed3 wLightDir = normalize(_WorldSpaceLightPos0);
               #else
               //���Դ�;۹�Ƶķ����ǹ�����-��������
               fixed3 wLightDir = normalize(_WorldSpaceLightPos0 - i.wpos);
               #endif
               fixed3 lambertColor = getLambertColor(i.wnormal, wLightDir);
               //���ַ��߹ⷴ��
               fixed3 phongSpecularColor = getBlinnPhoneSpecularColor(i.wnormal, i.wpos, wLightDir);

               //��ȡ���˥���͹������
               //������������
               #if defined(_DIRECTIONAL_LIGHT)
               //ƽ�й�û��˥����Ϣ
               fixed atten = 1;
               #elif defined(_POINT_LIGHT)
               //���Դ
               //�����������ռ�ת������Դ�ռ�
               fixed3 lightCoord = mul(unity_WorldToLight, float4(i.wpos, 1));
               //��CG��û��boolֵ ֻ��0��1������false��true�����Դ˴���lightCoord.z > 0���ж϶����ڹ��ǰ�����Ǻ�
               //�󷽱�ʾû���ܵ����˥��
               fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
               #elif defined(_SPOT_LIGHT)
               //�۹��
                //�����������ռ�ת������Դ�ռ�,����w�Ǿ۹����Ҫwȡ������˥����Ϣ
               fixed4 lightCoord = mul(unity_WorldToLight, float4(i.wpos, 1));
               //�۹��˥������_LightTextureB0���ȡ�ģ�����˥������_LightTexture0��ȡ
               fixed atten = (lightCoord.z > 0) 
               //��Ҫ�����������ӳ�䵽�������Ͻ��в���, ��Ҫ��uv����ӳ�䵽0~1�ķ�Χ�ٴ������в��ã�
               //lightCoord.xy / lightCoord.w �������ź�x��y��ȡֵ��Χ��-0.5~0.5֮�䣬����0.5ת����0~1
               * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w;
               * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).xx).UNITY_ATTEN_CHANNEL;
               #else
               //�����߼�
               fixed atten = 1;
               #endif
   
               //��Ϊ��Base Pass���һ�λ����⣬���Դ˴�����Ҫ����һ��
               fixed3 color = (lambertColor + phongSpecularColor) * atten;
               return fixed4(color, 1);
            }
            ENDCG
        }
    }
}
