using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class CustomShaderInspector : ShaderGUI
{
    private bool isShow;

    private CustomMaterialPropertyDrawer drawerFloat = new CustomMaterialPropertyDrawer(-2, 2);
    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        //base.OnGUI(materialEditor, properties);

        if (GUILayout.Button(isShow ? "隐藏所有属性设置" : "显示所有属性设置"))
            isShow = !isShow;
        //获取当前材质球
        Material material = materialEditor.target as Material;
        if (GUILayout.Button("重置材质球属性"))
        {
            material.SetTexture("_MainTex", null);
            material.SetFloat("_TestFloat", 0);
        }

        material.renderQueue = EditorGUILayout.IntField("渲染队列", material.renderQueue);

        if (isShow)
        {
            MaterialProperty prop = FindProperty("_TestFloat", properties);
            //自定义一个拖动条去设置TestFloat属性
            //这种单独获取某一个属性的方式 就不需要使用中间变量 以及 对应的材质球设置了
            //prop.floatValue = EditorGUILayout.Slider("自定义float属性", prop.floatValue, -1, 1);

            //MaterialProperty prop2 = FindProperty("_MainTex", properties);
            //materialEditor.ShaderProperty(prop2, prop2.displayName);

            foreach (var item in properties)
            {
                if (item.displayName == "TestFloat")
                {
                    //自定义一个拖动条去设置TestFloat属性
                    //item.floatValue = EditorGUILayout.Slider("自定义float属性", item.floatValue, -1, 1);
                    //material.SetFloat("_TestFloat", value);
                    drawerFloat.OnGUI(EditorGUILayout.GetControlRect(), item, item.displayName, materialEditor);
                }
                else
                    //利用获取到的一个个的材质属性 利用Unity自带的Inspector窗口UI显示方式去显示这些属性
                    materialEditor.ShaderProperty(item, item.displayName);
            }
        }
    }
}
