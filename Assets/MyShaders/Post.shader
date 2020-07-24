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

            bool enough_dpt_dist(float depth, float depth2, float depth_threshold){
                return (depth < depth_threshold) & (depth + 1 < depth2);
            }

            bool isEdge(float width, float depth_threshold, v2f i)
            {
                float w = width;
                float w2 = width * 0.7;

                float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));

                float depth__r = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(w,  0   ))));
                float depth_ur = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(w2,  w2 ))));
                float depth_u_ = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(0,  w   ))));
                float depth_ul = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(-w2, w2 ))));
                float depth__l = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(-w, 0   ))));
                float depth_dl = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(-w2, -w2))));
                float depth_d_ = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(0,  -w  ))));
                float depth_dr = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv + float2(w2,  -w2))));

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
                //float sm = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)));
                //return fixed4(sm > 1 ? 1 : 0, sm > 10 ? 1 : 0, sm > 100 ? 1 : 0, 1);

                bool isEdge_ = (isEdge(0.01, 10, i) | isEdge(0.003, 50, i) | isEdge(0.001, 10000, i));

                return isEdge_ ? fixed4(0,0,0,1) : tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
