using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Editor_RenderToCubeMap : EditorWindow
{
    private GameObject obj;
    private Cubemap cubeMap;
    [MenuItem("Shader�༭������/�������������������")]
    static void ShowWindow()
    {
        Editor_RenderToCubeMap window = EditorWindow.GetWindow<Editor_RenderToCubeMap>("�������������ɴ���");
        window.Show();
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("������ӦԤ���壺");
        obj = EditorGUILayout.ObjectField(obj, typeof(GameObject), true) as GameObject;
        EditorGUILayout.LabelField("������Ӧ����������");
        cubeMap = EditorGUILayout.ObjectField(cubeMap, typeof(Cubemap), true) as Cubemap;
        if (GUILayout.Button("��������������"))
        {
            if (obj == null || cubeMap == null)
            {
                EditorUtility.DisplayDialog("Error","���϶���ӦԤ���������������","OK");
                return;
            }
            GameObject tempObj = new GameObject("��ʱ����");
            tempObj.transform.position = obj.transform.position;
            Camera camera = tempObj.AddComponent<Camera>();
            camera.RenderToCubemap(cubeMap);
            DestroyImmediate(tempObj);
        }
    }
}
