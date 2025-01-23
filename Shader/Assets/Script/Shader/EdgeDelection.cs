using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDelection : PostEffectBase
{
    public Color EdgeColor;
    [Range(0,1)]
    public float BackGroundExtent = 0.5f;
    public Color BackGroundColor;
    protected override void UpdateProprety()
    {
        if (material != null)
        {
            material.SetColor("_EdgeColor", EdgeColor);
            material.SetFloat("_BackGroundExtent", BackGroundExtent);
            material.SetColor("_BackGroundColor", BackGroundColor);
        }
    }
}
