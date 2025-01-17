// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef EXTEND_UNITY_STANDARD_INPUT_INCLUDED
#define EXTEND_UNITY_STANDARD_INPUT_INCLUDED

#include "ExtendUnityCG.cginc"
#include "ExtendUnityStandardConfig.cginc"
#include "ExtendUnityGlobalIllumination.cginc"
#include "ExtendUnityStandardUtils.cginc"


//---------------------------------------
// Directional lightmaps & Parallax require tangent space too
#if (_NORMALMAP || DIRLIGHTMAP_COMBINED || _PARALLAXMAP)
    #define _TANGENT_TO_WORLD 1
#endif

#if (_DETAIL_MULX2 || _DETAIL_MUL || _DETAIL_ADD || _DETAIL_LERP)
    #define _DETAIL 1
#endif

//---------------------------------------
half4       _Color;
half        _Cutoff;

sampler2D   _MainTex;
float4      _MainTex_ST;

sampler2D   _DetailAlbedoMap;
float4      _DetailAlbedoMap_ST;

sampler2D   _BumpMap;
float4      _BumpMap_ST;
half        _BumpScale;

sampler2D   _DetailMask;
float4      _DetailMask_ST;
sampler2D   _DetailNormalMap;
half        _DetailNormalMapScale;

sampler2D   _SpecGlossMap;
sampler2D   _MetallicGlossMap;
half        _Metallic;
float       _Glossiness;
float       _GlossMapScale;

sampler2D   _OcclusionMap;
half        _OcclusionStrength;

sampler2D   _ParallaxMap;
half        _Parallax;
half        _UVSec;

half4       _EmissionColor;
sampler2D   _EmissionMap;
half4	    _EmissionMap_ST;
		
half4		_EmissionColor1;
sampler2D   _EmissionMap1;
half4		_EmissionMap1_ST;
sampler2D	_EmissionAlpha;
half4		_EmissionAlpha_ST;
half4		_EmissionBaseColor;

half		_VertexColorAlpha;

half4       _VertexColor;

half4  		_skin_color;
half4       _cap_sheild_color;
float 		_metal_smoothness;
float 		_unmetal_smoothness;
#ifndef _GPURIM
float 		_rim_range;
float4 		_rim_color;
float 		_rim_power;
#endif

half4       _RimColor;
half        _RimPower;

half4       _HeightFogColor;	
half4       _HeightFogEmissionColor;	
half4       _HeightFogParam;
half4       _HeightFogWave0;
half4       _HeightFogWave1;

UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

//-------------------------------------------------------------------------------------
// Input functions

struct VertexInput
{
    float4 vertex   : POSITION;
    half3 normal    : NORMAL;
	half4 color		: COLOR;
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    float2 uv2      : TEXCOORD2;
#endif
#ifdef _TANGENT_TO_WORLD
    half4 tangent   : TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
	
#ifdef	_GPUANIM 	
	uint vertexId:SV_VertexID;
#endif
};

float4 TexCoords(VertexInput v)
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0
#ifdef _UVANIMATION
	texcoord.xy += _Time.y * _MainTex_ST.zw;
#endif
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    return texcoord;
}

half DetailMask(float2 uv)
{
	uv = (uv - _MainTex_ST.zw) / _MainTex_ST.xy;
    return tex2D (_DetailMask, TRANSFORM_TEX(uv, _DetailMask)).r;
}

half3 Albedo(float4 texcoords)
{
    half3 albedo = tex2D (_MainTex, texcoords.xy).rgb;
#if _DETAIL
    #if (SHADER_TARGET < 30)
        // SM20: instruction count limitation
        // SM20: no detail mask
        half mask = 1;
    #else
        half mask = DetailMask(texcoords.xy);
    #endif
    half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
    #if _DETAIL_MULX2
        albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
    #elif _DETAIL_MUL
        albedo *= LerpWhiteTo (detailAlbedo, mask);
    #elif _DETAIL_ADD
        albedo += detailAlbedo * mask;
    #elif _DETAIL_LERP
        albedo = lerp (albedo, detailAlbedo, mask);
    #endif
#endif
	albedo *= _Color.rgb;
    return albedo;
}

half Alpha(float2 uv)
{
#if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
    return _Color.a;
#else
    return tex2D(_MainTex, uv).a * _Color.a;
#endif
}

half Occlusion(float2 uv)
{
#if (SHADER_TARGET < 30)
    // SM20: instruction count limitation
    // SM20: simpler occlusion
    return tex2D(_OcclusionMap, uv).g;
#else
    half occ = tex2D(_OcclusionMap, uv).g;
    return LerpOneTo (occ, _OcclusionStrength);
#endif
}

half4 SpecularGloss(float2 uv)
{
    half4 sg;
#ifdef _SPECGLOSSMAP
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
        sg.rgb = tex2D(_SpecGlossMap, uv).rgb;
        sg.a = tex2D(_MainTex, uv).a;
    #else
        sg = tex2D(_SpecGlossMap, uv);
    #endif
    sg.a *= _GlossMapScale;
#else
    sg.rgb = _SpecColor.rgb;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        sg.a = tex2D(_MainTex, uv).a * _GlossMapScale;
    #else
        sg.a = _Glossiness;
    #endif
#endif
    return sg;
}

half2 MetallicGloss(float2 uv)
{
    half2 mg;

#ifdef _METALLICGLOSSMAP
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.r = tex2D(_MetallicGlossMap, uv).r;
        mg.g = tex2D(_MainTex, uv).a;
    #elif _SMOOTHNESS_TEXTURE_METAL_G
		mg = tex2D(_MetallicGlossMap, uv).rg;
		//mg.g *= 2;
	#else
        mg = tex2D(_MetallicGlossMap, uv).ra;
    #endif
    mg.g *= _GlossMapScale;
#elif defined (_NORMALMETALLICGLOSSMAP)
    mg = tex2DN(_Normal, uv.xy);
    mg.g *= _GlossMapScale;
#else
    mg.r = _Metallic;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.g = tex2D(_MainTex, uv).a * _GlossMapScale;
    #else
        mg.g = _Glossiness;
    #endif
#endif
    return mg;
}

half2 MetallicRough(float2 uv)
{
    half2 mg;
#ifdef _METALLICGLOSSMAP
    mg.r = tex2D(_MetallicGlossMap, uv).r;
#else
    mg.r = _Metallic;
#endif

#ifdef _SPECGLOSSMAP
    mg.g = 1.0f - tex2D(_SpecGlossMap, uv).r;
#else
    mg.g = 1.0f - _Glossiness;
#endif
    return mg;
}

half3 Emission(float2 uv)
{
#if defined(_EMISSION_UNITY)
	uv = (uv - _MainTex_ST.zw) / _MainTex_ST.xy;
	return tex2D(_EmissionMap, TRANSFORM_TEX(uv,_EmissionMap)).rgb * _EmissionColor.rgb;
#elif  defined(_EMISSION_TYPE0)
	uv = (uv - _MainTex_ST.zw) / _MainTex_ST.xy;
	half2 uv0 = uv * _EmissionMap_ST.xy + _Time.y * _EmissionMap_ST.zw;
	half3 color0 = tex2D(_EmissionMap, uv0).rgb * _EmissionColor.rgb;
	
	half2 uv1 = uv * _EmissionMap1_ST.xy + _Time.y * _EmissionMap1_ST.zw;
	half3 color1 = tex2D(_EmissionMap1, uv1).rgb * _EmissionColor1.rgb;
	
	half2 uv2 = uv * _EmissionAlpha_ST.xy + _EmissionAlpha_ST.zw;
	
	half alpha = tex2D(_EmissionAlpha, uv2).r;
	return color0 + lerp(_EmissionBaseColor.rgb,color1,alpha);
#else
    return 0;
#endif
}

#ifdef _NORMALMAP
half3 NormalInTangentSpace(float4 texcoords, out half3 normalTangent_flake)
{
	half2 uv = (texcoords.xy - _MainTex_ST.zw) / _MainTex_ST.xy;
    half3 normalTangent = UnpackScaleNormal(tex2D (_BumpMap, TRANSFORM_TEX(uv,_BumpMap)), _BumpScale);    

#if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
    half mask = DetailMask(texcoords.xy);
    half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
    #if _DETAIL_LERP
        normalTangent = lerp(
            normalTangent,
            detailNormalTangent,
            mask);
    #else
        normalTangent = lerp(
            normalTangent,
            BlendNormals(normalTangent, detailNormalTangent),
            mask);
    #endif
#endif

    normalTangent_flake = normalTangent;

#if _FLAKENORMAL
    // Apply scaled flake normal map
	float2 scaledUV = texcoords.xy * _FlakesBumpMapScale;
	half3 flakeNormal = UnpackNormal(tex2D (_FlakesBumpMap, scaledUV));

	// Apply flake map strength
	half3 scaledFlakeNormal = flakeNormal;
	scaledFlakeNormal.xy *= _FlakesBumpStrength;
	scaledFlakeNormal.z = 0; // Z set to 0 for better blending with other normal map.

	// Blend regular normal map with flakes normal map
	normalTangent_flake = normalize(normalTangent + scaledFlakeNormal);
#endif

    return normalTangent;
}
#endif

float4 Parallax (float4 texcoords, half3 viewDir)
{
#if !defined(_PARALLAXMAP) || (SHADER_TARGET < 30)
    // Disable parallax on pre-SM3.0 shader target models
    return texcoords;
#else
    half h = tex2D (_ParallaxMap, texcoords.xy).g;
    float2 offset = ParallaxOffset1Step (h, _Parallax, viewDir);
    return float4(texcoords.xy + offset, texcoords.zw + offset);
#endif

}

#endif // UNITY_STANDARD_INPUT_INCLUDED
