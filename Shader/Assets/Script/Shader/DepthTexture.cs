using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthTexture:PostEffectBase
{
    private void Start()
    {
        //可以在Shader中得到对应的深度纹理信息了
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
}
