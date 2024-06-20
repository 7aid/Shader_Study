using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class Editor_Window : EditorWindow
{
    [MenuItem("�Զ�����չ����/EditorGUILayout�༭������")]
    public static void ShowWindow()
    {
        Editor_Window window = EditorWindow.GetWindow<Editor_Window>();
        window.titleContent = new GUIContent("EditorGUILayout�༭������");
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

    AnimationCurve animation;


    Vector2 vector2;
    private void OnGUI()
    {
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        layer = EditorGUILayout.LayerField("�㼶ѡ��", layer);
        tag = EditorGUILayout.TagField("��ǩѡ��", tag);
        color = EditorGUILayout.ColorField(new GUIContent("������ɫ"), color , true, true, false);
        type1 = (E_TestType)EditorGUILayout.EnumPopup("ö��ѡ��", type1);
        type2 = (E_TestType)EditorGUILayout.EnumFlagsField("��ѡö��ѡ��", type2);
        testNum = EditorGUILayout.IntPopup("������ѡ��", testNum, testStringArray, testNumArray);
        if (EditorGUILayout.DropdownButton(new GUIContent("�����������"), FocusType.Passive))
            Debug.Log("�����������");

        foldout = EditorGUILayout.Foldout(foldout, "�۵�");
        if (foldout)
        {
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
        }
        foldoutGroup = EditorGUILayout.BeginFoldoutHeaderGroup(foldoutGroup, "�۵���");
        if (foldoutGroup)
        {
            img = EditorGUILayout.ObjectField(img, typeof(Image), false) as Image;

            i = EditorGUILayout.IntField("Int�����", i);
            EditorGUILayout.LabelField(i.ToString());
            l = EditorGUILayout.LongField("long�����", l);
            f = EditorGUILayout.FloatField("Float ���룺", f);
            d = EditorGUILayout.DoubleField("double ���룺", d);

            str = EditorGUILayout.TextField("Text���룺", str);
            vec2 = EditorGUILayout.Vector2Field("Vec2���룺 ", vec2);
            vec3 = EditorGUILayout.Vector3Field("Vec3���룺 ", vec3);
            vec4 = EditorGUILayout.Vector4Field("Vec4���룺 ", vec4);

            rect = EditorGUILayout.RectField("rect���룺 ", rect);
            bounds = EditorGUILayout.BoundsField("Bounds���룺 ", bounds);
            boundsInt = EditorGUILayout.BoundsIntField("Bounds���룺 ", boundsInt);

            i2 = EditorGUILayout.DelayedIntField("Int�����", i2);
            EditorGUILayout.LabelField(i2.ToString());
        }
        EditorGUILayout.EndFoldoutHeaderGroup();

        toogle = EditorGUILayout.Toggle("����", toogle);
        tooglel = EditorGUILayout.ToggleLeft("���������", tooglel);
        toogleg = EditorGUILayout.BeginToggleGroup("������", toogleg);
        if (toogleg)
        {
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
            EditorGUILayout.LabelField("�ı�����", "�ı�����");
        }       
        EditorGUILayout.EndToggleGroup();

        sliderf = EditorGUILayout.Slider("������", sliderf, 1, 10);
        slideri = EditorGUILayout.IntSlider("����ֵ������", slideri, 1, 10);
        EditorGUILayout.MinMaxSlider("˫�黬����", ref sleft, ref sright, 1, 10);

        EditorGUILayout.HelpBox("һ����ʾ", MessageType.None);
        EditorGUILayout.HelpBox("��̾����ʾ", MessageType.Info);
        EditorGUILayout.HelpBox("���������ʾ", MessageType.Warning);
        EditorGUILayout.HelpBox("���������ʾ", MessageType.Error);

        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.Space(10);
        EditorGUILayout.LabelField("�ı�����", "�ı�����");

        animation = EditorGUILayout.CurveField("�������ߣ�", animation);

        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.EndHorizontal();

        vector2 =  EditorGUILayout.BeginScrollView(vector2);
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.LabelField("�ı�����", "�ı�����");
        EditorGUILayout.EndScrollView();

    }
}
