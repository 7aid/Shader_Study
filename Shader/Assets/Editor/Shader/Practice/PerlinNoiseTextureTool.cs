using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class PerlinNoiseTextureTool : EditorWindow
{
    //纹理宽高
    private int textureWidth = 512;
    private int textureHeight = 512;
    //缩放
    private int scale = 20;
    //保存的纹理名
    private string textureName = "perlinNoiseTexture";

    [MenuItem("柏林噪声纹理生成工具/打开")]
    public static void ShowWindow() 
    {
        GetWindow<PerlinNoiseTextureTool>("柏林噪声纹理生成工具");
    }

    private void OnGUI()
    {
        GUILayout.Label("柏林噪声纹理设置");
        textureWidth = EditorGUILayout.IntField("纹理宽", textureWidth);
        textureHeight = EditorGUILayout.IntField("纹理高", textureHeight);
        scale = EditorGUILayout.IntField("缩放", scale);

        textureName = EditorGUILayout.TextField("纹理名", textureName);

        if (GUILayout.Button("生成柏林噪声纹理"))
        {
            //生成柏林纹理的逻辑
            //根据纹理的图片坐标 去得到对应的噪声值 然后将噪声值 存储到颜色信息中 RGB是相同
            Texture2D texture = new Texture2D(textureWidth, textureHeight);
            for (int y = 0; y < textureHeight; y++)
            {
                for (int x = 0; x < textureWidth; x++)
                {
                    float noiseValue = Mathf.PerlinNoise((float)x/textureWidth * scale, (float)y/textureHeight * scale);
                    texture.SetPixel(x, y, new Color(noiseValue, noiseValue, noiseValue));
                }
            }
            texture.Apply();
            File.WriteAllBytes("Assets/Resource/Pic/Noise/" + textureName + ".png", texture.EncodeToPNG());
            AssetDatabase.Refresh();

            EditorUtility.DisplayDialog("提示", "噪声纹理生成结束", "确定");
        }
    }
}
