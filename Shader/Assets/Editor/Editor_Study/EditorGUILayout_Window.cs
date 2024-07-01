using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class EditorGUILayout_Window : EditorWindow
{
    [MenuItem("自定义扩展窗口/EditorGUILayout编辑器窗口")]
    public static void ShowWindow()
    {
        EditorGUILayout_Window window = EditorWindow.GetWindow<EditorGUILayout_Window>();
        window.titleContent = new GUIContent("EditorGUILayout编辑器窗口");
        window.Show();
    }
    public enum E_TestType
    {
        One = 1,
        Two = 2,
        Three = 4,
        One_and_Two = 1 | 2,
    }
    int layer;
    string tag;
    Color color;
    E_TestType type1;
    E_TestType type2;
    int testNum;
    int[] testNumArray = { 1, 2, 3 };
    string[] testStringArray = {"Choose1", "Choose2", "Choose3" };
    Image img;

    int i;
    int i2;
    float f;
    double d;
    long l;

    string str;
    Vector2 vec2;
    Vector3 vec3;
    Vector4 vec4;

    Rect rect;
    Bounds bounds;
    BoundsInt boundsInt;

    bool foldout;
    bool foldoutGroup;

    bool toogle;
    bool tooglel;
    bool toogleg;

    float sliderf;
    int slideri;

    float sleft;
    float sright;

    AnimationCurve animation = new AnimationCurve();


    Vector2 vector2;
    private void OnGUI()
    {
        EditorGUILayout.LabelField("文本标题", "文本内容");
        layer = EditorGUILayout.LayerField("层级选择", layer);
        tag = EditorGUILayout.TagField("标签选择", tag);
        color = EditorGUILayout.ColorField(new GUIContent("测试颜色"), color , true, true, false);
        type1 = (E_TestType)EditorGUILayout.EnumPopup("枚举选择", type1);
        type2 = (E_TestType)EditorGUILayout.EnumFlagsField("多选枚举选择", type2);
        testNum = EditorGUILayout.IntPopup("整数单选框", testNum, testStringArray, testNumArray);
        if (EditorGUILayout.DropdownButton(new GUIContent("点击立即触发"), FocusType.Passive))
            Debug.Log("点击立即触发");

        foldout = EditorGUILayout.Foldout(foldout, "折叠");
        if (foldout)
        {
            EditorGUILayout.LabelField("文本标题", "文本内容");
            EditorGUILayout.LabelField("文本标题", "文本内容");
            EditorGUILayout.LabelField("文本标题", "文本内容");
        }
        foldoutGroup = EditorGUILayout.BeginFoldoutHeaderGroup(foldoutGroup, "折叠组");
        if (foldoutGroup)
        {
            img = EditorGUILayout.ObjectField(img, typeof(Image), false) as Image;

            i = EditorGUILayout.IntField("Int输入框", i);
            EditorGUILayout.LabelField(i.ToString());
            l = EditorGUILayout.LongField("long输入框", l);
            f = EditorGUILayout.FloatField("Float 输入：", f);
            d = EditorGUILayout.DoubleField("double 输入：", d);

            str = EditorGUILayout.TextField("Text输入：", str);
            vec2 = EditorGUILayout.Vector2Field("Vec2输入： ", vec2);
            vec3 = EditorGUILayout.Vector3Field("Vec3输入： ", vec3);
            vec4 = EditorGUILayout.Vector4Field("Vec4输入： ", vec4);

            rect = EditorGUILayout.RectField("rect输入： ", rect);
            bounds = EditorGUILayout.BoundsField("Bounds输入： ", bounds);
            boundsInt = EditorGUILayout.BoundsIntField("Bounds输入： ", boundsInt);

            i2 = EditorGUILayout.DelayedIntField("Int输入框", i2);
            EditorGUILayout.LabelField(i2.ToString());
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        toogle = EditorGUILayout.Toggle("开关", toogle);
        tooglel = EditorGUILayout.ToggleLeft("开关在左侧", tooglel);
        toogleg = EditorGUILayout.BeginToggleGroup("开关组", toogleg);
        if (toogleg)
        {
            EditorGUILayout.LabelField("文本标题", "文本内容");
            EditorGUILayout.LabelField("文本标题", "文本内容");
            EditorGUILayout.LabelField("文本标题", "文本内容");
        }       
        EditorGUILayout.EndToggleGroup();

        sliderf = EditorGUILayout.Slider("滑动条", sliderf, 1, 10);
        slideri = EditorGUILayout.IntSlider("整数值滑动条", slideri, 1, 10);
        EditorGUILayout.MinMaxSlider("双块滑动条", ref sleft, ref sright, 1, 10);

        EditorGUILayout.HelpBox("一般提示", MessageType.None);
        EditorGUILayout.HelpBox("感叹号提示", MessageType.Info);
        EditorGUILayout.HelpBox("警告符号提示", MessageType.Warning);
        EditorGUILayout.HelpBox("错误符号提示", MessageType.Error);

        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("文本标题", "文本内容");

        animation = EditorGUILayout.CurveField("动画曲线：", animation);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.EndHorizontal();

        vector2 =  EditorGUILayout.BeginScrollView(vector2);
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.LabelField("文本标题", "文本内容");
        EditorGUILayout.EndScrollView();

    }
}
