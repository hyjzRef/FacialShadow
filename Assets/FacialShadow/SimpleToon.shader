Shader "Unlit/SimpleToon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("MaskTex", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) = (1,1,1,1)
        _ShadeColor ("ShadeColor", Color) = (1,1,1,1)
        _ShadeStep ("ShadeStep", Range(0, 1)) = 0.5
        _ShadeFeather ("ShadeFeather", Range(0.0001, 1)) = 0.0001
    }
    SubShader
    {
        Tags {"RenderPipeline" = "UniversalPipeline"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord0 : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 posWS : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);SAMPLER(sampler_MainTex);float4 _MainTex_ST;
            TEXTURE2D(_MaskTex);SAMPLER(sampler_MaskTex);float4 _MaskTex_ST;
            float4 _BaseColor;
            float4 _ShadeColor;
            float _ShadeFeather;
            float _ShadeStep;
            float _IsFaceTo;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.posWS = float4(TransformObjectToWorld(v.vertex.xyz), 1.0);
                o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
                o.normalDir = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                Light mainLight = GetMainLight();
                float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(i.uv, _MainTex));
                float4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, TRANSFORM_TEX(i.uv, _MaskTex));
                
                float2 lightDir = normalize(mainLight.direction.xz);
                float2 normalDir = normalize(i.normalDir.xz);
                float halfLambert = 0.5 * dot(normalDir, lightDir) + 0.5;
                float thresholdOffset = 0.5 * (halfLambert + lerp(1 - mask.b, mask.b, _IsFaceTo));
                
                float3 baseColor = _BaseColor.rgb * col.rgb;
                float3 shadeColor = _ShadeColor.rgb * col.rgb;
                float shadowMask = saturate(
                    1.0 - (thresholdOffset - _ShadeStep + _ShadeFeather) / _ShadeFeather
                );
                
                float3 finalColor = lerp(baseColor, shadeColor, shadowMask);
                return float4(finalColor.xyz, col.a);
            }
            ENDHLSL
        }
    }
}
