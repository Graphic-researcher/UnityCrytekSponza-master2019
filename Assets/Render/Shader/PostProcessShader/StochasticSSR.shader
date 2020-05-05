﻿Shader "Hidden/DragonStochasticSSR" {

	CGINCLUDE
		#include "StochasticSSR.cginc"
	ENDCG

	SubShader {
		ZTest Always 
		ZWrite Off
		Cull Front

		Pass 
		{
			Name"HierarchicalZBuffer"
			CGPROGRAM
				#pragma vertex VertDefault
				#pragma fragment Hierarchical_ZBuffer
			ENDCG
		}	


/*
		Pass 
		{
			Name"Pass_Hierarchical_ZTrace_SingleSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Hierarchical_ZTrace_SingleSPP
			ENDCG
		} 	

		Pass 
		{
			Name"Pass_Hierarchical_ZTrace_MultiSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Hierarchical_ZTrace_MultiSPP
			ENDCG
		} 

		Pass 
		{
			Name"Pass_Spatiofilter_SingleSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Spatiofilter_SingleSPP
			ENDCG
		} 

		Pass 
		{
			Name"Pass_Spatiofilter_MultiSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Spatiofilter_MultiSPP
			ENDCG
		} 


		Pass 
		{
			Name"Pass_Temporalfilter_SingleSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Temporalfilter_SingleSPP
			ENDCG
		} 

		Pass 
		{
			Name"Pass_Temporalfilter_MultiSampler"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment Temporalfilter_MultiSPP
			ENDCG
		} 

		Pass 
		{
			Name"Pass_CombineReflection"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment CombineReflectionColor
			ENDCG
		}

		Pass 
		{
			Name"Pass_DeBug_SSRColor"
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment DeBug_SSRColor
			ENDCG
		}		
		
		*/
		
		
	}
}
