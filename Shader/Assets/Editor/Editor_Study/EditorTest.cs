using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class EditorTest : Editor
{
    [MenuItem("ҳǩ/һ��ѡ��/����ѡ��")]
    private static void EditorTest01()
    {
        Debug.Log("EditorTest01");
    }
    [MenuItem("GameObject/ҳǩ/һ��ѡ��/����ѡ��")]
    private static void EditorTest02()
    {
        Debug.Log("EditorTest02");
    }
    [MenuItem("Assets/ҳǩ/һ��ѡ��/����ѡ��")]
    private static void EditorTest03()
    {
        Debug.Log("EditorTest03");
    }
    [MenuItem("CONTEXT/Light/��ӽű�")]
    private static void EditorTest05()
    {
        Debug.Log("EditorTest05");
    }
    [MenuItem("��ݼ�/����� _A")]
    private static void EditorTest06()
    {
        Debug.Log("EditorTest06");
    }
    [MenuItem("��ݼ�/��Ͽ�� _%#&A")]
    private static void EditorTest07()
    {
        Debug.Log("EditorTest07");
    }

}
