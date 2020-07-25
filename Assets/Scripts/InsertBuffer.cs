using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class InsertBuffer : MonoBehaviour
{
    [SerializeField] Material[] postProcessMats;
    new Camera camera;

    void Start()
    {
        camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.Depth;
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;

        foreach(Material mat in postProcessMats){
            InsertPostProcess(mat, mat.name);
        }
    }

    void InsertPostProcess(Material material, string name){
        CommandBuffer buffer = CreateBuffer(name);
        SetBlit(buffer, material, name);
        camera.AddCommandBuffer(CameraEvent.BeforeImageEffects, buffer);
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
