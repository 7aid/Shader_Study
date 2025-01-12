using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestScreenPosProcessing : MonoBehaviour
{
    public Material material;
    // Start is called before the first frame update
    void Start()
    {
        
    }
    //加入该特性 就不会对透明物体产生影响
    //[ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //把源纹理 通过 材质球当中的Shader进行效果处理 然后写入到目标纹理中 最终呈现在屏幕上
        Graphics.Blit(source, destination, material);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
