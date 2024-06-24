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
        EditorGUIUtility_Window window = EditorWindow.GetWindow<EditorGUIUtility_Window>();
        window.titleContent = new GUIContent("EditorGUIUtility编辑器窗口");
        window.Show();
    }

    Texture img;
    Texture img1;

    private void OnGUI()
    {
        if (GUILayout.Button("加载一张图片"))
        {
            string imgName = "img_editor.png";
            img = EditorGUIUtility.Load(imgName) as Texture;
            if (img != null)
                GUI.DrawTexture(new Rect(100, 100, 50, 50), img);
            else
                Debug.LogError("加载图片失败：" + imgName);
        }
       
    }
}
