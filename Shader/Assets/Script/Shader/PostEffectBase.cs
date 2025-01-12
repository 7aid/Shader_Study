using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//用于使脚本在编辑器模式下也能执行
[ExecuteInEditMode] 
//指定某个脚本所依赖的组件，它确保当你将脚本附加到游戏对象时，所需的组件也会自动添加到该游戏对象中
//如果这些组件已经存在，它们不会被重复添加,因为后处理脚本一般添加到摄像机上，因此我们用于依赖摄像机
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    public Shader shader;

    private Material _material;

    protected Material material 
    {
        get {
            if (shader == null || !shader.isSupported)
                return null;
            else
            {
                if (_material != null && _material.shader == shader)
                    return _material;
                _material = new Material(shader);
                //不希望材质球被保存下来 因此我们家一个标识
                _material.hideFlags = HideFlags.DontSave;
                return _material;
            }
        }
    }

    protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        UpdateProprety();

        if (material != null)
            Graphics.Blit(source, destination, material);
        else
            Graphics.Blit(source, destination);
    }

    protected virtual void UpdateProprety()
    {

    }
}
