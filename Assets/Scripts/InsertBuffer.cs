using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class InsertBuffer : MonoBehaviour
{
    [SerializeField] Material postProcessMat;

    void Start()
    {
        CommandBuffer buffer = CreateBuffer("Comical");
        SetBlit(buffer, postProcessMat, "PostProcess");
        GetComponent<Camera>().AddCommandBuffer(CameraEvent.BeforeImageEffects, buffer);
    }

    CommandBuffer CreateBuffer(string name){
        CommandBuffer buf = new CommandBuffer();
        buf.name = name;
        return buf;
    }

    void SetBlit(CommandBuffer buffer, Material material, string name){
        int id = Shader.PropertyToID(name);

        buffer.GetTemporaryRT(id, -1, -1);
        buffer.Blit(BuiltinRenderTextureType.CameraTarget, id);
        buffer.Blit(id, BuiltinRenderTextureType.CameraTarget, material);
        buffer.ReleaseTemporaryRT(id);
    }
}
