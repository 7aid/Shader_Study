Shader "Custom/Test_01"
{
    Properties
    {
        _MyInt("MyInt", Int) = 1
        _MyFloat("MyFloat", Float) = 1.2
        _MyRange("MyRange", Range(1,10)) = 5

        _My2D("_My2D", 2D) = ""{}
        _My2DAarry("_2DArray", 2DArray) = ""{}
        _My3D("_My3D", 3D) = ""{}
        _MyCube("_MyCbue", Cube) = ""{}       
    }
    SubShader {
        //��Ⱦ��ǩ -- ��Ⱦ����
        Tags{"Queue" = "TransParent"}

        //��Ⱦͨ��
        Pass {
            // ����
            Name "TagPass"
            // ��Pass ��͸��
            Tags{"RenderType" = "Opaque"}
        }
    }

    FallBack "Diffuse"
}
