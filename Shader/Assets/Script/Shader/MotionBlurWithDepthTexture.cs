using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture:PostEffectBase
{
    [Range(0, 1)]
    public float blurSize = .5f;
    //用于记录上一次的变换矩阵的变量
    private Matrix4x4 frontWorldToClipMatrix;
    private void Start()
    {
        //可以在Shader中得到对应的深度纹理信息了
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
            //设置模糊程度
            material.SetFloat("_BlurSize", blurSize);
            //设置上一帧世界空间到裁剪空间的矩阵
            material.SetMatrix("_FrontWorldToClipMatrix", frontWorldToClipMatrix);
            //计算这一帧的变换矩阵
            frontWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
            //设置这一帧的 裁剪到世界空间的变换矩阵
            material.SetMatrix("_ClipToWorldMatrix", frontWorldToClipMatrix.inverse);
            //进行屏幕后处理
            Graphics.Blit(source, destination, material);
        }
        else 
        {
            Graphics.Blit(source, destination);
        }
    }
}
