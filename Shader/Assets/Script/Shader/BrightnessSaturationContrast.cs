using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessSaturationContrast : PostEffectBase
{
    [Range(0,5)]
    public float brightness;
    [Range(0, 5)]
    public float saturation;
    [Range(0, 5)]
    public float contrast;


    protected override void UpdateProprety()
    {
        if (material != null)
        {
            material.SetFloat("_Brightness", brightness);
            material.SetFloat("_Saturation", saturation);
            material.SetFloat("_Contrast", contrast);
        }
    }
}
