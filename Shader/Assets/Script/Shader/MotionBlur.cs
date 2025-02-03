using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    [Range(0, 0.9f)]
    public float blurAmount = .5f;
    //�ѻ����� ���ڴ洢֮ǰ��Ⱦ�Ľṹ�� ��Ⱦ����
    private RenderTexture accumulation;
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            if (accumulation == null 
                || accumulation.width != source.width 
                || accumulation.height != source.height)
            {
                DestroyImmediate(accumulation);
                //��ʼ��
                accumulation = new RenderTexture(source.width, source.height, 0);
                accumulation.hideFlags = HideFlags.HideAndDontSave;
                //��֤��һ�� �ۻ�������Ҳ�������� ��Ϊ֮��������ɫ����Ϊ��ɫ����������ɫ
                Graphics.Blit(source, accumulation);
            }
            //1 - ģ���̶ȵ�Ŀ�� ����Ϊ ϣ���󵽵�Ч���� ģ���̶�ֵԽ�� Խģ��
            //��ΪShader�еĻ�����ӵļ��㷽ʽ������ ��� ������Ҫ1 - ��
            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            //�������ǵĲ��ʽ��л�ϴ���
            //�ڶ������� ������ʱ  ������Ϊ��ɫ����������ɫ�����д���
            //û��ֱ��д��Ŀ���е�Ŀ�� Ҳ�ǿ���ͨ��accumulationTex��¼��ǰ��Ⱦ���
            //��ô����һ��ʱ �����൱������һ�εĽ����
            Graphics.Blit(source, accumulation, material);

            Graphics.Blit(accumulation, destination);
        }
        else 
        {
            Graphics.Blit(source, destination);
        }
    }

    //�ű�ʧ�����Ҫɾ���ۻ�����
    private void OnDisable()
    {
        DestroyImmediate(accumulation);
    }
}
