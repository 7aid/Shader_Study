using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CSharpDynamicTexture : MonoBehaviour
{
    public int width = 256;
    public int height = 256;

    public int count = 8;
    public Color colorA = Color.white;
    public Color colorB = Color.black;

    private void Awake()
    {
        RefreshTexture();
    }

    public void RefreshTexture()
    {
        Texture2D mainTexture = new Texture2D(width, height);
        int cellW = width / count;
        int cellH = height / count;
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                //首先需要知道 格子的宽高是多少
                //textureWidth / tileCount = 格子的宽
                //textureHeight / tileCount = 格子的高

                // x / 格子的宽（56）= 当前x所在格子编号
                // y / 格子的高 (56) = 当前y所在格子编号

                //要判断一个数 是偶数还是奇数 直接对2取余 如果是0 则为偶数 如果为1 则为奇数
                //判断 x 和 y 方向 格子索引 是否同奇 或者 同偶              
                if ( x / cellW % 2 == y / cellH % 2)
                    mainTexture.SetPixel(x, y, colorA);
                else
                    mainTexture.SetPixel(x, y, colorB);
            }
        }

        mainTexture.Apply();

        Renderer render = this.GetComponent<Renderer>();
        if (render != null)
            render.sharedMaterial.mainTexture = mainTexture;

    }
}
