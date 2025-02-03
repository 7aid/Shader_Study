using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
{
    [Range(0, 0.9f)]
    public float blurAmount = .5f;
    //堆积纹理 用于存储之前渲染的结构的 渲染纹理
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
                //初始化
                accumulation = new RenderTexture(source.width, source.height, 0);
                accumulation.hideFlags = HideFlags.HideAndDontSave;
                //保证第一次 累积纹理中也是有内容 因为之后它的颜色会作为颜色缓冲区的颜色
                Graphics.Blit(source, accumulation);
            }
            //1 - 模糊程度的目的 是因为 希望大到的效果是 模糊程度值越大 越模糊
            //因为Shader中的混合因子的计算方式决定的 因此 我们需要1 - 它
            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            //利用我们的材质进行混合处理
            //第二个参数 有内容时  它会作为颜色缓冲区的颜色来进行处理
            //没有直接写入目标中的目的 也是可以通过accumulationTex记录当前渲染结果
            //那么在下一次时 它就相当于是上一次的结果了
            Graphics.Blit(source, accumulation, material);

            Graphics.Blit(accumulation, destination);
        }
        else 
        {
            Graphics.Blit(source, destination);
        }
    }

    //脚本失活的需要删除累积纹理
    private void OnDisable()
    {
        DestroyImmediate(accumulation);
    }
}
