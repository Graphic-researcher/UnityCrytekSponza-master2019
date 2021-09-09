Shader "Hidden/DragonHBAO"
{
	Properties {
		_MainTex ("", 2D) = "" {}
		_HBAOTex ("", 2D) = "" {}
		_NoiseTex("", 2D) = "" {}
	}

	CGINCLUDE
		#pragma target 3.0

		#include "UnityCG.cginc"

		#if !defined(UNITY_UNROLL)
			#if defined(UNITY_COMPILER_HLSL)
				#define UNITY_UNROLL	[unroll]
			#else
				#define UNITY_UNROLL
			#endif
		#endif

		sampler2D _MainTex;
		sampler2D _HBAOTex;
		float4 _MainTex_TexelSize;

		sampler2D_float _CameraDepthTexture;
		sampler2D _NormalBufferTex;
		
		sampler2D_float _NoiseTex;

		float4 _CameraDepthTexture_ST;
	
		float4 _UVToView;
		float _MaxRadiusPixels;
		float _AORadius;
		float _AOIntensity;
		float _AngleBias;//解决Low-Tessellation,在切面角加一个偏移量
		float _NegInvRadius2;
		float _AOmultiplier;
		float _MaxDistance;
		float _DistanceFalloff;		
		half4 _AOColor;				
		float _BlurSharpness;		

		struct v2f {
			float2 uv : TEXCOORD0;
			float2 uv2 : TEXCOORD1;
		};

		v2f vert(appdata_img v, out float4 outpos : SV_POSITION) {
			v2f o;
			o.uv = v.texcoord.xy;
			o.uv2 = v.texcoord.xy;
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				o.uv2.y = 1 - o.uv2.y;
			#endif
			outpos = UnityObjectToClipPos(v.vertex);
			return o;
		}

		inline half4 FetchOcclusion(float2 uv) {

			half4 occ = tex2D(_HBAOTex, uv);

			occ.r = saturate(pow(occ.r, _AOIntensity));
			return occ;
		}

		inline half4 FetchSceneColor(float2 uv) {

			half4 col = tex2D(_MainTex, uv);
			return col;
		}

	ENDCG

	SubShader {
		ZTest Always Cull Off ZWrite Off

		// 0: hbao pass (lowest quality)
		Pass {
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag_ao

				//分三个方向步进
				#define DIRECTIONS		3
				#define STEPS			2
				#include "hbao.cginc"

			ENDCG
		}
		
		// 1: hbao pass (low quality)
		Pass {
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag_ao
				//分四个方向步进
				#define DIRECTIONS		4
				//光线步进次数
				#define STEPS			3
				#include "hbao.cginc"

			ENDCG
		}

		// 2: hbao pass (medium quality)
		Pass {
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag_ao
				//分六个方向步进
				#define DIRECTIONS		6
				#define STEPS			4
				#include "hbao.cginc"

			ENDCG
		}

		// 3: hbao pass (high quality)
		Pass {
			CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag_ao
				//分八个方向步进
				#define DIRECTIONS		8
				#define STEPS			4
				#include "hbao.cginc"

			ENDCG
		}		

		// 4: blur X pass 
		Pass {
			CGPROGRAM

				#pragma vertex vertBlurH
				#pragma fragment fragBlur

				#include "hbaoBlur.cginc"

			ENDCG
		}	

		// 5: blur Y pass 
		Pass {
			CGPROGRAM

				#pragma vertex vertBlurV
				#pragma fragment fragBlur

				#include "hbaoBlur.cginc"

			ENDCG
		}	
	
		// 6: composite pass
		Pass {
			Blend DstColor Zero
			//ColorMask RGB
			CGPROGRAM

				#pragma vertex vert							
				#pragma fragment frag			
			
				half4 frag (v2f i) : SV_Target {
					half4 occ = FetchOcclusion(i.uv2);
					half3 ao = lerp(_AOColor.rgb, half3(1.0, 1.0, 1.0), occ.r);
					return half4(ao, 1);
				}
				
			ENDCG
		}		

		// 7: show pass (AO only)
		Pass {
			CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag
				
				half4 frag (v2f i) : SV_Target {
					half4 ao = FetchOcclusion(i.uv2);
					half3 aoColor = lerp(_AOColor.rgb, half3(1.0, 1.0, 1.0), ao.r);
					return half4(aoColor, 1.0);
				}
				
			ENDCG
		}

	}

	FallBack off
}
