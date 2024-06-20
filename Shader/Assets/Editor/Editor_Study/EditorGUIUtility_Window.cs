using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class EditorGUIUtility_Window : EditorWindow
{
    [MenuItem("自定义扩展窗口/EditorGUIUtility编辑器窗口")]
    public static void ShowWindow()
    {
        Editor_Window window = EditorWindow.GetWindow<Editor_Window>();
        window.titleContent = new GUIContent("EditorGUIUtility编辑器窗口");
        window.Show();
    }

}
