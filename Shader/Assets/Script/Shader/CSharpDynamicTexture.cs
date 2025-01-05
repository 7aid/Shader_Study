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
                //������Ҫ֪�� ���ӵĿ���Ƕ���
                //textureWidth / tileCount = ���ӵĿ�
                //textureHeight / tileCount = ���ӵĸ�

                // x / ���ӵĿ�56��= ��ǰx���ڸ��ӱ��
                // y / ���ӵĸ� (56) = ��ǰy���ڸ��ӱ��

                //Ҫ�ж�һ���� ��ż���������� ֱ�Ӷ�2ȡ�� �����0 ��Ϊż�� ���Ϊ1 ��Ϊ����
                //�ж� x �� y ���� �������� �Ƿ�ͬ�� ���� ͬż              
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
