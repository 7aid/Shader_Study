//�����ع����𶥵����
Shader "MyShader/Lambort_vert"
{
    Properties
    {
        //���ʵ�����������
        _LambortColor("_LambortColor",Color) = (1,1,1,1)
    }
    SubShader
    {
        //��Ⱦ��ǩ����ʾ��͸��������ǰ��Ⱦ
        Tags{"LightMode" = "ForwardBase"}
        //��Ⱦͨ��
        Pass
        {
            CGPROGRAM
            //������ɫ������ָ��
            #pragma vertex vert
            //ƬԪ��ɫ����������
            #pragma fragment frag
            //���ö�Ӧ�������ļ� 
            //��Ҫ��Ϊ��֮�� �� �������ýṹ��ʹ�ã����ñ���ʹ��
            #include "UnityCG.cginc"          
            #include "Lighting.cginc"

            fixed4 _LambortColor;
           
            //������ɫ�����ݸ�ƬԪ��ɫ��������
            struct v2f
            {
                ////�ü��ռ��µĶ���������Ϣ
                float4 pos:SV_POSITION;
                //��Ӧ����������������ɫ
                fixed3 color:COLOR;
            };

            //�𶥵���� ������ص������������ɫ�ļ��� ��Ҫд�ڶ�����ɫ�� �ص�������
            v2f vert(appdata_base data)
            {
                v2f v2f;
                //��ģ�Ϳռ�ĵ�ת�����ü��ռ�
                v2f.pos = UnityObjectToClipPos(data.vertex);
                //��ȡģ�Ϳռ��������ռ��ı�׼������
                fixed3 dataNormal = UnityObjectToWorldNormal(data.normal);
                //��ȡ����ռ��Դ��׼������
                fixed3 lightNomralizeDir = normalize(_WorldSpaceLightPos0.xyz);
                //��ȡ����ռ��Դ��ģ�Ϳռ�����ɫ         
                v2f.color = _LightColor0.rgb * _LambortColor.rgb * max(0, dot(lightNomralizeDir, dataNormal));
                //�����ع���ģ�ͻ����������ģ����������Ӱ��Ӱ�죬�������屻�����䲻���ĵط���ȫ�ڰ�
                v2f.color = v2f.color + UNITY_LIGHTMODEL_AMBIENT.rgb;
                return v2f;
            }

            fixed4 frag(v2f v2f):SV_Target
            {
                //�ڴ˴����������������ɫ(͸��ֵĬ��Ϊ1)
                return fixed4(v2f.color.rgb, 1);
            }
            ENDCG    
        }
    }
}



