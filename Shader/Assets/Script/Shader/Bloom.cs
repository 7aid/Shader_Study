using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
{
    //亮度阈值变量
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
            //设置亮度阈值变量
            material.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //渲染纹理缓冲区
            RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer.filterMode = FilterMode.Bilinear;
            //提取 用我们的提取Pass去得到对应的亮度信息  存入缓冲纹理中
            Graphics.Blit(source, buffer, material, 0);

            //第二步 模糊处理
            //多次去执行 高斯模糊逻辑
            for (int i = 0;  i < iterations; i++)
            {
                material.SetFloat("_BlurSpeed", 1 + i * blurSpread);

                //又声明一个新的缓冲区
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //因为我们需要用两个Pass 处理图像两次 
                //进行第一次 水平卷积计算
                Graphics.Blit(buffer, buffer1, material, 1); //Color1
                //这时 关键内容都在buffer1中 buffer没用了 释放掉
                RenderTexture.ReleaseTemporary(buffer);

                buffer = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                //进行第二次 垂直卷积计算
                Graphics.Blit(buffer, buffer1, material, 2);//在Color1的基础上乘上Color2 得到最终的高斯模糊计算结果
                                                            //释放缓存区
                RenderTexture.ReleaseTemporary(buffer);
                //buffer和buffer1指向的都是这一次高斯模糊处理的结果
                buffer = buffer1;
            }

            //把提取出来的内容进行高斯模糊后 存储Shader当中的一个纹理变量
            //用于之后进行合成
            material.SetTexture("_Bloom", buffer);
            //测试代码  用于看到提取效果
            //Graphics.Blit(buffer, destination);


            //合成步骤
            Graphics.Blit (source, destination, material, 3);

            RenderTexture.ReleaseTemporary(buffer);
            
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
