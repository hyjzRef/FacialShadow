using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoRatation : MonoBehaviour
{

    public Vector3 speed;

    // Update is called once per frame
    void Update()
    {
        transform.localEulerAngles += speed * Time.deltaTime;
    }
}
