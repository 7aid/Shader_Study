using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    //������ֵ����
    [Range(0,4)]
    public float luminanceThreshold = .5f;

    [Range(1, 8)]
    public int downSample = 1;
    [Range(1, 16)]
    public int iterations = 1;
    [Range(0, 3)]
    public float blurSpread = .6f;

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            //����������ֵ����
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //��Ⱦ��������
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer.filterMode = FilterMode.Bilinear;
            //��ȡ �����ǵ���ȡPassȥ�õ���Ӧ��������Ϣ  ���뻺��������
            Graphics.Blit(source, buffer, material, 0);

            //�ڶ��� ģ������
            //���ȥִ�� ��˹ģ���߼�
            for (int i = 0;  i < iterations; i++)
            {
                material.SetFloat("_BlurSpeed", 1 + i * blurSpread);

                //������һ���µĻ�����
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //��Ϊ������Ҫ������Pass ����ͼ������ 
                //���е�һ�� ˮƽ�������
                Graphics.Blit(buffer, buffer1, material, 1); //Color1
                //��ʱ �ؼ����ݶ���buffer1�� bufferû���� �ͷŵ�
                RenderTexture.ReleaseTemporary(buffer);

                buffer = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                //���еڶ��� ��ֱ�������
                Graphics.Blit(buffer, buffer1, material, 2);//��Color1�Ļ����ϳ���Color2 �õ����յĸ�˹ģ��������
                                                            //�ͷŻ�����
                RenderTexture.ReleaseTemporary(buffer);
                //buffer��buffer1ָ��Ķ�����һ�θ�˹ģ������Ľ��
                buffer = buffer1;
            }

            //����ȡ���������ݽ��и�˹ģ���� �洢Shader���е�һ���������
            //����֮����кϳ�
            material.SetTexture("_Bloom", buffer);
            //���Դ���  ���ڿ�����ȡЧ��
            //Graphics.Blit(buffer, destination);


            //�ϳɲ���
            Graphics.Blit (source, destination, material, 3);

            RenderTexture.ReleaseTemporary(buffer);
            
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
