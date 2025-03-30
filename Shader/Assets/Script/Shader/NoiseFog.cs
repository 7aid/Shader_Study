using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NoiseFog : PostEffectBase
{
    //雾的颜色
    public Color fogColor = Color.gray;
    //雾的浓度
    [Range(0, 3)]
    public float fogDensity = 1f;
    //雾开始的距离
    public float fogStart = 0f;
    //雾最浓的距离
    public float fogEnd = 5f;

    //矩阵  用于传递矩阵转换
    private Matrix4x4 rayMatrix;

    public Texture noiseTexture;
    public float noiseAmount;
    public float fogXSpeed;
    public float fogYSpeed;

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }

    protected override void UpdateProprety()
    {
        if (material != null)
        {
            //得到摄像机视口夹角
            float fov = Camera.main.fieldOfView / 2f;
            //得到近裁剪面距离
            float near = Camera.main.nearClipPlane;
            //得到窗口比例
            float aspect = Camera.main.aspect;

            //计算高的一半
            float halfH = near * Mathf.Tan(fov * Mathf.Deg2Rad);
            //宽的一半
            float halfW = halfH * aspect;

            //计算竖直向上的和水平向右的偏移向量
            Vector3 toTop = Camera.main.transform.up * halfH;
            Vector3 toRight = Camera.main.transform.right * halfW;
            //算出指向四个顶点的向量
            Vector3 TL = Camera.main.transform.forward * near + toTop - toRight;
            Vector3 TR = Camera.main.transform.forward * near + toTop + toRight;
            Vector3 BL = Camera.main.transform.forward * near - toTop - toRight;
            Vector3 BR = Camera.main.transform.forward * near - toTop + toRight;
            //为了让深度值计算出来时两点间的距离 所以需要乘以一个缩放值
            float scale = TL.magnitude / near;
            //真正的最终想要的四条射线向量
            TL = TL.normalized * scale;
            TR = TR.normalized * scale;
            BL = BL.normalized * scale;
            BR = BR.normalized * scale;

            rayMatrix.SetRow(0, BL);
            rayMatrix.SetRow(1, BR);
            rayMatrix.SetRow(2, TR);
            rayMatrix.SetRow(3, TL);

            //设置材质球相关属性(Shader属性)
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetMatrix("_RayMatrix", rayMatrix);

            material.SetTexture("_Noise", noiseTexture);
            material.SetFloat("_NoiseAmount", noiseAmount);
            material.SetFloat("_FogXSpeed", fogXSpeed);
            material.SetFloat("_FogYSpeed", fogYSpeed);
        }
    }
}
