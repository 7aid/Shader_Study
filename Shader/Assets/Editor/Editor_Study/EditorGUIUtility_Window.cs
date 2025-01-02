using UnityEditor;
using UnityEngine;

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
    Texture img2;
    Rect rect = new Rect(0, 300, 100, 100);
    Color color;
    AnimationCurve curve = new AnimationCurve();

    private void OnGUI()
    {
        string imgName = "img_editor.png";
        if (GUILayout.Button("Load加载一张图片"))
        {
            img = EditorGUIUtility.Load(imgName) as Texture;          
        }
        if (img != null)
            GUI.DrawTexture(new Rect(0, 100, 100, 100), img);
        if (GUILayout.Button("LoadRequired加载一张图片"))
        {
            img1 = EditorGUIUtility.LoadRequired(imgName) as Texture;
        }
        if (img1 != null)
            GUI.DrawTexture(new Rect(0, 200, 100, 100), img1);

        if (GUILayout.Button("打开搜索框查询窗口"))
        {
            EditorGUIUtility.ShowObjectPicker<Texture>(null, false, "Editor", 0);
        }
        if (Event.current.commandName == "ObjectSelectorUpdated")
        {
            img2 = EditorGUIUtility.GetObjectPickerObject() as Texture;
            if (img2 != null)
                Debug.LogError("当前选中图片：" + img2.name);
            Debug.LogError("搜索框选中事件更新");
        }
        if (Event.current.commandName == "ObjectSelectorClosed")
        {
            img2 = EditorGUIUtility.GetObjectPickerObject() as Texture;
            if (img2 != null)
                Debug.LogError("关闭后当前选中图片：" + img2.name);
            Debug.LogError("搜索框关闭事件更新");
        }
        if (GUILayout.Button("选中高亮显示"))
        {
            if (img2 != null)
            {
                EditorGUIUtility.PingObject(img2);
            }
        }
        if (GUILayout.Button("传递事件"))
        {
            Event e = EditorGUIUtility.CommandEvent("EditorGUIUtilityEventTest");
            EditorWindow editorWindow = EditorWindow.GetWindow<EditorGUIUtility_Window>();
            editorWindow.SendEvent(e);
        }
        if (Event.current.type == EventType.ExecuteCommand)
        {
            if ((Event.current.commandName == "EditorGUIUtilityEventTest"))
            {
                Debug.LogError("其它窗口向此窗口传递一个事件!!!");
            }
        }

        if (GUILayout.Button("坐标转换测试"))
        {
            Vector2 v = new Vector2(10, 10);
            GUI.BeginGroup(new Rect(10, 10, 100, 100));
            //转换函数 如果包裹在布局相关函数中 那么位置胡加上布局的偏移 再进行转换
            Vector2 screenPos = EditorGUIUtility.GUIToScreenPoint(v);
            GUI.EndGroup();
            Debug.LogError("GUI: " + v + "Screen:  " + screenPos);
        }

        EditorGUI.DrawRect(rect, Color.green);
        EditorGUIUtility.AddCursorRect(rect, MouseCursor.Text);

        color = EditorGUILayout.ColorField(new GUIContent("选取颜色"), color, true, true , true);
        EditorGUIUtility.DrawColorSwatch(new Rect(0, 180, 30, 30), color);

        curve = EditorGUILayout.CurveField(new GUIContent("绘画曲线"), curve);
        EditorGUIUtility.DrawCurveSwatch(new Rect(0, 210, 50 , 50), curve, null, Color.red, Color.white);
    }
}
