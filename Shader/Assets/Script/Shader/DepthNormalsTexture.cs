using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthNormalsTexture : PostEffectBase
{
    private void Start()
    {
        //������Shader�еõ���Ӧ�����������Ϣ��
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
    }
}
