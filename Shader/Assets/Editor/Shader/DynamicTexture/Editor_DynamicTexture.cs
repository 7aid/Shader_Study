using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CSharpDynamicTexture))]
public class Editor_DynamicTexture : Editor
{
    public override void OnInspectorGUI()
    {
        //����Ĭ�ϲ�����ص�����
        DrawDefaultInspector();

        CSharpDynamicTexture obj = target as CSharpDynamicTexture;
        if (GUILayout.Button("���³�������"))
        {
            obj.RefreshTexture();
        }
    }
}
