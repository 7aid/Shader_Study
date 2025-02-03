using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture:PostEffectBase
{
    //雾的颜色
    public Color fogColor = Color.gray;
    //雾的浓度
    [Range(0, 3)]
    public float fogDensity = 1f;
    //雾开始的距离
    public float fogStart = 0f;
    //雾最浓时的距离
    public float fogEnd = 5f;

    //4x4的矩阵 用于传递4个向量参数
    private Matrix4x4 rayMatrix;

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
    protected override void UpdateProprety()
    {
        if (material != null) 
        {
            //获取摄像机的视口夹角
            float fov = Camera.main.fieldOfView / 2f;
            //获取近裁剪面距离
            float near = Camera.main.nearClipPlane;
            //得到窗口宽高比例
            float aspect = Camera.main.aspect;

            //计算出高的一半(对边/邻边)
            float halfH = near * Mathf.Tan(fov * Mathf.Deg2Rad);
            //宽的一半
            float halfW = halfH * aspect;
            //计算竖直向上和水平向右的偏移向量
            Vector3 toTop = Camera.main.transform.up * halfH;
            Vector3 toRight = Camera.main.transform.right * halfW;
            //计算出四个顶点的向量(Camera.main.transform.forward * near == 近裁剪面的中心点)
            Vector3 nearCenterPos = Camera.main.transform.forward * near;
            Vector3 TL = nearCenterPos + toTop - toRight;
            Vector3 TR = nearCenterPos + toTop + toRight;
            Vector3 BL = nearCenterPos - toTop - toRight;
            Vector3 BR = nearCenterPos - toTop + toRight;
            //为了让深度值计算出来是两点间距离，所以需要乘以一个缩放值(利用相似三角形的原理)
            float scale = TL.magnitude / near;
            //获取最终的四条射线向量
            TL = TL.normalized * scale;
            TR = TR.normalized * scale;
            BL = BL.normalized * scale;
            BR = BR.normalized * scale;

            rayMatrix.SetRow(0, BL);
            rayMatrix.SetRow(1, BR);
            rayMatrix.SetRow(2, TR);
            rayMatrix.SetRow(3, TL);


            //设置材质球相关属性
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetMatrix("_RayMatrix", rayMatrix);
        } 
    }
}
