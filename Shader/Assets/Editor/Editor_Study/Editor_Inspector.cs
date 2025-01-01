using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

[CustomEditor(typeof(TestEditorInspector))]
public class Editor_Inspector : Editor
{
    //属性
    SerializedProperty atk;
    SerializedProperty def;
    SerializedProperty obj;
    //数组和列表
    SerializedProperty ints;
    SerializedProperty gameObjects;

    SerializedProperty listObjs;
    //类
    SerializedProperty testClass;
    SerializedProperty testClassI;
    SerializedProperty testClassF;

    private bool foldOut;
    private int count;
    private void OnEnable()
    {
        atk = serializedObject.FindProperty("atk");
        def = serializedObject.FindProperty("def");
        obj = serializedObject.FindProperty("obj");

        ints = serializedObject.FindProperty("ints");
        gameObjects = serializedObject.FindProperty("gameObjects");

        listObjs = serializedObject.FindProperty("listObjs");

        testClass = serializedObject.FindProperty("testClass");
        //testClassI = testClass.FindPropertyRelative("i");
        //testClassF = testClass.FindPropertyRelative("f");
        testClassI = serializedObject.FindProperty("testClass.i");
        testClassF = serializedObject.FindProperty("testClass.f");
    }

    public override void OnInspectorGUI()
    {
        //base.OnInspectorGUI();
        serializedObject.Update();

        foldOut = EditorGUILayout.BeginFoldoutHeaderGroup(foldOut, "基础属性");
        if (foldOut) 
        {
            if (GUILayout.Button("测试自定义Inspector窗口")) 
            {
                Debug.LogError(target.name);
            }
            EditorGUILayout.IntSlider(atk, 0, 100, "攻击力");
            def.floatValue = EditorGUILayout.FloatField("防御力", def.floatValue);
            EditorGUILayout.ObjectField(obj, new GUIContent("敌对对象"));
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        //容量设置
        count = EditorGUILayout.IntField("List容量", count);

        //是否要缩减 移除尾部的内容
        //从后往前去移除 避免移除不干净
        //当容量变少时 才会走这的逻辑
        for (int i = listObjs.arraySize - 1; i >= count; i--)
            listObjs.DeleteArrayElementAtIndex(i);

        //根据容量绘制需要设置的每一个索引位置的对象
        for (int i = 0; i < count; i++)
        {
            //去判断如果数组或者LIst容量不够 去通过插入的形式去扩容
            if (listObjs.arraySize <= i)
                listObjs.InsertArrayElementAtIndex(i);

            SerializedProperty indexPro = listObjs.GetArrayElementAtIndex(i);
            EditorGUILayout.ObjectField(indexPro, new GUIContent($"索引{i}"));
        }
        EditorGUILayout.Space(10);

        EditorGUILayout.PropertyField(ints, new GUIContent("int数组"));
        EditorGUILayout.PropertyField(gameObjects, new GUIContent("gameobj列表"));

        EditorGUILayout.PropertyField(testClass, new GUIContent("自定义属性"));

        testClassI.intValue = EditorGUILayout.IntField("自定义属性I", testClassI.intValue);
        testClassF.floatValue = EditorGUILayout.FloatField("自定义属性F", testClassF.floatValue);
        serializedObject.ApplyModifiedProperties();
    }
}
