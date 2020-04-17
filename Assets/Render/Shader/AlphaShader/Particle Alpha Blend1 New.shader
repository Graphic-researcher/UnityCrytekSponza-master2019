// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Particles/Alpha Blended_game New" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	 _SoftParticleFade ("softParticleFade", Vector) = (0,1,0,0)
        _CameraFade ("cameraFade", Vector) = (1,2,0,0)
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha , Zero OneMinusSrcAlpha
	//ColorMask RGB
	Cull Off Lighting Off ZWrite Off Fog{ Mode Off }

	SubShader {
		Pass {
			//FOG off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			//#pragma multi_compile_fog
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
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
			#if _ALPHABUFFER
    float4 projectedPosition : TEXCOORD2;
#endif
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
			#if _ALPHABUFFER
    o.projectedPosition = ComputeScreenPos (o.vertex); 
    COMPUTE_EYEDEPTH(o.projectedPosition.z);
#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}


            float _InvFade;

            fixed4 frag (v2f i) : SV_Target
            {
#if _ALPHABUFFER 
	float sceneZ = LinearEyeDepth (SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projectedPosition))); 
	clip(sceneZ - i.projectedPosition.z);	
#endif 

				
				fixed4 col =2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
#if _ALPHABUFFER
    float softParticlesFade = 1.0f; 
    if (_SoftParticleFade.x > 0.0 || _SoftParticleFade.y > 0.0) 
    { 	
        softParticlesFade = saturate (_SoftParticleFade.y * ((sceneZ - _SoftParticleFade.x) - i.projectedPosition.z)); 
        col.a *= softParticlesFade;		
    }
	float cameraFade = saturate((i.projectedPosition.z - _CameraFade.x) * _CameraFade.y); 
    col.a *= cameraFade;
#endif
				col.a = saturate(col.a); 
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return col ;
			}
			ENDCG 
		}
	}	
}
}