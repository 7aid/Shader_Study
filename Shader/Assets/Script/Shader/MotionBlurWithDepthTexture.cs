using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture:PostEffectBase
{
    [Range(0, 1)]
    public float blurSize = .5f;
    //���ڼ�¼��һ�εı任����ı���
    private Matrix4x4 frontWorldToClipMatrix;
    private void Start()
    {
        //������Shader�еõ���Ӧ�����������Ϣ��
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnEnable()
    {
        frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
    }

    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            //����ģ���̶�
            material.SetFloat("_BlurSize", blurSize);
            //������һ֡����ռ䵽�ü��ռ�ľ���
            material.SetMatrix("_FrontWorldToClipMatrix", frontWorldToClipMatrix);
            //������һ֡�ı任����
            frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
            //������һ֡�� �ü�������ռ�ı任����
            material.SetMatrix("_ClipToWorldMatrix", frontWorldToClipMatrix.inverse);
            //������Ļ����
            Graphics.Blit(source, destination, material);
        }
        else 
        {
            Graphics.Blit(source, destination);
        }
    }
}
