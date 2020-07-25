Shader "CustomPostProcess/NormalEdge"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WidthNear ("Width (near)", Float) = 0.01
        _WidthMiddle ("Width (middle)", Float) = 0.003
        _WidthFar ("Width (far)", Float) = 0.001
        _LineColor("Line Color", Color) = (0,0,0,1)
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
            sampler2D _CameraDepthNormalsTexture;
            float _WidthNear;
            float _WidthMiddle;
            float _WidthFar;
            float4 _LineColor;

            bool enough_dpt_dist(float depth, float depth2, float depth_threshold){
                return (depth < depth_threshold) & (depth + 1 < depth2);
            }

            float sampleLinearDepth(float2 uv){
                return LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, uv)));
            }

            bool isEdge(float width, float depth_threshold, v2f i)
            {
                float w = width;
                float w2 = width * 0.7;

                float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));

                float depth__r = sampleLinearDepth(i.uv + float2(w,  0   ));
                float depth_ur = sampleLinearDepth(i.uv + float2(w2,  w2 ));
                float depth_u_ = sampleLinearDepth(i.uv + float2(0,  w   ));
                float depth_ul = sampleLinearDepth(i.uv + float2(-w2, w2 ));
                float depth__l = sampleLinearDepth(i.uv + float2(-w, 0   ));
                float depth_dl = sampleLinearDepth(i.uv + float2(-w2, -w2));
                float depth_d_ = sampleLinearDepth(i.uv + float2(0,  -w  ));
                float depth_dr = sampleLinearDepth(i.uv + float2(w2,  -w2));

                return   enough_dpt_dist(depth__r, depth, depth_threshold)
                       | enough_dpt_dist(depth_ur, depth, depth_threshold)
                       | enough_dpt_dist(depth_u_, depth, depth_threshold)
                       | enough_dpt_dist(depth_ul, depth, depth_threshold)
                       | enough_dpt_dist(depth__l, depth, depth_threshold)
                       | enough_dpt_dist(depth_dl, depth, depth_threshold)
                       | enough_dpt_dist(depth_d_, depth, depth_threshold)
                       | enough_dpt_dist(depth_dr, depth, depth_threshold);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_CameraDepthNormalsTexture, i.uv);

                bool isEdge_ = (isEdge(_WidthNear, 10, i) | isEdge(_WidthMiddle, 50, i) | isEdge(_WidthFar, 10000, i));

                return isEdge_ ? _LineColor : tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
