// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Legacy Shaders/Particles/Alpha Blended Premultiply New" {
Properties {
    _MainTex ("Particle Texture", 2D) = "white" {}
     _SoftParticleFade ("softParticleFade", Vector) = (0,1,0,0)
        _CameraFade ("cameraFade", Vector) = (1,2,0,0)
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend One OneMinusSrcAlpha,Zero OneMinusSrcAlpha

    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_particles
  #pragma multi_compile __ _ALPHABUFFER

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _TintColor;

	float4 _SoftParticleFade;
			float4 _CameraFade;			
			UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);	
            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
   #if _ALPHABUFFER
    float4 projectedPosition : TEXCOORD2;
#endif
                UNITY_VERTEX_OUTPUT_STEREO
            };

            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
#if _ALPHABUFFER
    o.projectedPosition = ComputeScreenPos (o.vertex); 
    COMPUTE_EYEDEPTH(o.projectedPosition.z);
#endif

                o.color = v.color;
                o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }


            float _InvFade;

            fixed4 frag (v2f i) : SV_Target
            {
#if _ALPHABUFFER 
	float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projectedPosition))); 
	clip(sceneZ - i.projectedPosition.z);	
#endif
		half4 col = i.color * tex2D(_MainTex, i.texcoord) * i.color.a;
#if _ALPHABUFFER
    float softParticlesFade = 1.0f; 
    if (_SoftParticleFade.x > 0.0 || _SoftParticleFade.y > 0.0) 
    { 	
        softParticlesFade = saturate (_SoftParticleFade.y * ((sceneZ - _SoftParticleFade.x) - i.projectedPosition.z)); 
        col.rgb *= softParticlesFade;		
    }
	float cameraFade = saturate((i.projectedPosition.z - _CameraFade.x) * _CameraFade.y); 
    col.rgb *= cameraFade;
#endif	
                return col;
            }
            ENDCG
        }
    }
}
}
