using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class ObjectCutting : MonoBehaviour
{
    private Material material;
    //切割对象 用于决定切割位置
    public GameObject curObj;
    void Start()
    {
        material = this.GetComponent<Renderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        if (material != null && curObj != null)
            material.SetVector("_CuttingPos", curObj.transform.position);
    }
}
