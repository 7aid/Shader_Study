using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


public class EditorSelection_Window : EditorWindow
{
    [MenuItem("自定义扩展窗口/EditorSelection窗口")]
    public static void ShowWindow()
    {
        EditorWindow editorWindow = EditorWindow.GetWindow(typeof(EditorSelection_Window));
        editorWindow.titleContent = new GUIContent("EditorSelection窗口");
        editorWindow.Show();
    }

    private void OnEnable()
    {
        Selection.selectionChanged += SelectionChanged;
    }

    private void OnDisable()
    {
        Selection.selectionChanged -= SelectionChanged;
    }

    private void SelectionChanged()
    {
        Debug.LogError("选择的对象改变");
    }

    Texture obj;
    private void OnGUI()
    {
        if (GUILayout.Button("获取当前选中物体名称"))
        {
            if (Selection.activeObject != null)
            {
                Debug.Log(Selection.activeObject.name);
            }
        }

        if (GUILayout.Button("获取当前所有选中物体名称"))
        {
            if (Selection.objects != null)
            {
                for (int i = 0; i < Selection.objects.Length; i++)
                {
                    if (Selection.objects[i] != null)
                    {
                        Debug.Log(Selection.objects[i].name);
                    }
                }              
            }
        }

        obj = EditorGUILayout.ObjectField(obj, typeof(Texture), false) as Texture;
        if (GUILayout.Button("是否选中"))
        {
            if(Selection.Contains(obj))
            {
                Debug.LogError("obj物体正在被选中");
            }
            else
            {
                Debug.LogError("obj物体没有被选中");
            }
        }

        if (GUILayout.Button("筛选所有对象"))
        {
            Object[] objs = Selection.GetFiltered(typeof(Texture), SelectionMode.Assets | SelectionMode.DeepAssets);
            for (int i = 0; i < objs.Length; i++)
            {
                Debug.Log(objs[i].name);
            }
        }
    }
}
