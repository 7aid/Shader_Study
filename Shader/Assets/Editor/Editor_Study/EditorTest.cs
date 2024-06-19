using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EditorTest : Editor
{
    [MenuItem("页签/一级选项/二级选项")]
    private static void EditorTest01()
    {
        Debug.Log("EditorTest01");
    }
    [MenuItem("GameObject/页签/一级选项/二级选项")]
    private static void EditorTest02()
    {
        Debug.Log("EditorTest02");
    }
    [MenuItem("Assets/页签/一级选项/二级选项")]
    private static void EditorTest03()
    {
        Debug.Log("EditorTest03");
    }
    [MenuItem("CONTEXT/Light/添加脚本")]
    private static void EditorTest05()
    {
        Debug.Log("EditorTest05");
    }
    [MenuItem("快捷键/单快捷 _A")]
    private static void EditorTest06()
    {
        Debug.Log("EditorTest06");
    }
    [MenuItem("快捷键/组合快捷 _%#&A")]
    private static void EditorTest07()
    {
        Debug.Log("EditorTest07");
    }

}
