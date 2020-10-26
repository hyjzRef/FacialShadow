using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class UpdateProperty : MonoBehaviour
{
    public Transform mainLight;

    public Material mat;

    void Update()
    {
        if (!mainLight || !mat)
            return;
        Vector2 lightDir = new Vector2(mainLight.forward.x, mainLight.forward.z);
        Vector2 faceDir = new Vector2(transform.forward.x, transform.forward.z);
        float faceTo = Vector2.SignedAngle(faceDir, lightDir) > 0 ? 1 : 0;
        mat.SetFloat("_IsFaceTo", faceTo);
    }
}
