using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTexture:PostEffectBase
{
    //�����ɫ
    public Color fogColor = Color.gray;
    //���Ũ��
    [Range(0, 3)]
    public float fogDensity = 1f;
    //��ʼ�ľ���
    public float fogStart = 0f;
    //����Ũʱ�ľ���
    public float fogEnd = 5f;

    //4x4�ľ��� ���ڴ���4����������
    private Matrix4x4 rayMatrix;

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
    }
    protected override void UpdateProprety()
    {
        if (material != null) 
        {
            //��ȡ��������ӿڼн�
            float fov = Camera.main.fieldOfView / 2f;
            //��ȡ���ü������
            float near = Camera.main.nearClipPlane;
            //�õ����ڿ�߱���
            float aspect = Camera.main.aspect;

            //������ߵ�һ��(�Ա�/�ڱ�)
            float halfH = near * Mathf.Tan(fov * Mathf.Deg2Rad);
            //���һ��
            float halfW = halfH * aspect;
            //������ֱ���Ϻ�ˮƽ���ҵ�ƫ������
            Vector3 toTop = Camera.main.transform.up * halfH;
            Vector3 toRight = Camera.main.transform.right * halfW;
            //������ĸ����������(Camera.main.transform.forward * near == ���ü�������ĵ�)
            Vector3 nearCenterPos = Camera.main.transform.forward * near;
            Vector3 TL = nearCenterPos + toTop - toRight;
            Vector3 TR = nearCenterPos + toTop + toRight;
            Vector3 BL = nearCenterPos - toTop - toRight;
            Vector3 BR = nearCenterPos - toTop + toRight;
            //Ϊ�������ֵ����������������룬������Ҫ����һ������ֵ(�������������ε�ԭ��)
            float scale = TL.magnitude / near;
            //��ȡ���յ�������������
            TL = TL.normalized * scale;
            TR = TR.normalized * scale;
            BL = BL.normalized * scale;
            BR = BR.normalized * scale;

            rayMatrix.SetRow(0, BL);
            rayMatrix.SetRow(1, BR);
            rayMatrix.SetRow(2, TR);
            rayMatrix.SetRow(3, TL);


            //���ò������������
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_FogDensity", fogDensity);
            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetMatrix("_RayMatrix", rayMatrix);
        } 
    }
}
