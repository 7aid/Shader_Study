using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class EditorGUIUtility_Window : EditorWindow
{
    [MenuItem("�Զ�����չ����/EditorGUIUtility�༭������")]
    public static void ShowWindow()
    {
        Editor_Window window = EditorWindow.GetWindow<Editor_Window>();
        window.titleContent = new GUIContent("EditorGUIUtility�༭������");
        window.Show();
    }

}
