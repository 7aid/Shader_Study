using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

public class TestEditorInspector : MonoBehaviour
{
    public int atk;
    public float def;
    public GameObject obj;


    public int[] ints = new int[2];
    public List<GameObject> gameObjects = new List<GameObject>();

    public List<Object> listObjs = new List<Object>();

    public MyInspectorClass testClass = new MyInspectorClass();

    void Start()
    {
        
    }

    void Update()
    {
        
    }
}

[Serializable]
public class MyInspectorClass
{
    public int i;
    public float f;
}
