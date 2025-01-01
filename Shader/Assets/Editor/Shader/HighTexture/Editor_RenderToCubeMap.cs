using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Editor_RenderToCubeMap : EditorWindow
{
    private GameObject obj;
    private Cubemap cubeMap;
    [MenuItem("Shader编辑器测试/打开生成立方体纹理界面")]
    static void ShowWindow()
    {
        Editor_RenderToCubeMap window = EditorWindow.GetWindow<Editor_RenderToCubeMap>("立方体纹理生成窗口");
        window.Show();
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("关联对应预制体：");
        obj = EditorGUILayout.ObjectField(obj, typeof(GameObject), true) as GameObject;
        EditorGUILayout.LabelField("关联对应立方体纹理：");
        cubeMap = EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), true) as Cubemap;
        if (GUILayout.Button("生成立方体纹理"))
        {
            if (obj == null || cubeMap == null)
            {
                EditorUtility.DisplayDialog("Error","请拖动对应预制体和立方体纹理","OK");
                return;
            }
            GameObject tempObj = new GameObject("临时对象");
            tempObj.transform.position = obj.transform.position;
            Camera camera = tempObj.AddComponent<Camera>();
            camera.RenderToCubemap(cubeMap);
            DestroyImmediate(tempObj);
        }
    }
}
