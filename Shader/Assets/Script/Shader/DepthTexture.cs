using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTexture:PostEffectBase
{
    private void Start()
    {
        //������Shader�еõ���Ӧ�����������Ϣ��
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}
