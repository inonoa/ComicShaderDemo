Shader "Unlit/Comical"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ShadeColor ("Shade Color", Color) = (0, 0, 1, 1)
        _ShadeThreshold ("Shade Threshold", Range(0, 1)) = 0.2
        _DotDensity ("Dot Density", Int) = 100
        _DotRadius ("Dot Radius", Float) = 0.002
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        ZWrite On

        Pass
        {
            Name "ShadowCast"
            Tags {
                "LightMode" = "ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float4 viewportPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _ShadeColor;
            float _ShadeThreshold;
            int _DotDensity;
            float _DotRadius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewportPos = ComputeScreenPos(o.vertex);
                return o;
            }

            bool blackOnTone(v2f i){
                float aspect = _ScreenParams.x / _ScreenParams.y;
                float2 uv_in_screen = float2(
                    (i.viewportPos.x / i.viewportPos.w) * aspect,
                    i.viewportPos.y / i.viewportPos.w
                );
                float dot2dot = 1.0 / (_DotDensity - 1.0);
                float distanceFromDot2 = 
                      pow((dot2dot / 2.0) - abs((uv_in_screen.x % dot2dot) - (dot2dot / 2.0)), 2)
                    + pow((dot2dot / 2.0) - abs((uv_in_screen.y % dot2dot) - (dot2dot / 2.0)), 2);
                return (distanceFromDot2 <= _DotRadius * _DotRadius);
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float4 lightDir = mul(UNITY_MATRIX_M, WorldSpaceLightDir(i.vertex));
                float luminance = 0.5 + 0.5 * dot(normalize(i.worldNormal), normalize(lightDir.xyz));
                return ((luminance < _ShadeThreshold) & blackOnTone(i)) ? fixed4(0,0,0,1) : _Color;
            }
            
            ENDCG
        }
    }
}
