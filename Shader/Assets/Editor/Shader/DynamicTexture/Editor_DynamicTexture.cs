using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CSharpDynamicTexture))]
public class Editor_DynamicTexture : Editor
{
    public override void OnInspectorGUI()
    {
        //绘制默认参数相关的内容
        DrawDefaultInspector();

        CSharpDynamicTexture obj = target as CSharpDynamicTexture;
        if (GUILayout.Button("更新程序纹理"))
        {
            obj.RefreshTexture();
        }
    }
}
