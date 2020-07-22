Shader "Hidden/Post"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed depth       = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                fixed depth_right = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(1.0/100, 0)));
                fixed depth_left  = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv - float2(1.0/100, 0)));
                fixed depth_up    = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(0, 1.0/100)));
                fixed depth_down  = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv - float2(0, 1.0/100)));

                bool isEdge = depth + 0.02 < depth_right
                            | depth + 0.02 < depth_left
                            | depth + 0.02 < depth_up
                            | depth + 0.02 < depth_down;

                return isEdge ? fixed4(0,0,0,1) : tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
