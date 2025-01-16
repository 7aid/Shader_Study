using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDelection : PostEffectBase
{
    public Color edgeColor;
    protected override void UpdateProprety()
    {
        if (material != null)
        {
            material.SetColor("_EdgeColor", edgeColor);
        }
    }
}
