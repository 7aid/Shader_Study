using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript:PostEffectBase
{
    [Range(0,1)]
    public float edgeOnly = 0;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;
    public float sampleDistance = 1;
    public float sensitivityDepth = 1;
    public float sensitivityNormal = 1;

    private void Start()
    {
        //����ر�������� Ӱ��������Ļ����Ч��
        Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    protected override void UpdateProprety()
    {
        if (material != null)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetFloat("_SensitivityDepth", sensitivityDepth);
            material.SetFloat("_SensitivityNormal", sensitivityNormal);
        }
    }
}
