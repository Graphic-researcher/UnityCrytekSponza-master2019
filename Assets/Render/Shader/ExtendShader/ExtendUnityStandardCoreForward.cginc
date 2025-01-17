// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

#ifndef EXTEND_UNITY_STANDARD_CORE_FORWARD_INCLUDED
#define EXTEND_UNITY_STANDARD_CORE_FORWARD_INCLUDED

#if defined(UNITY_NO_FULL_STANDARD_SHADER)
#   define UNITY_STANDARD_SIMPLE 1
#endif

#include "ExtendUnityStandardConfig.cginc"

#if 0
    #include "UnityStandardCoreForwardSimple.cginc"
    VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); }
    VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }
    half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); }
    half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); }
#else
    #include "ExtendUnityStandardCore.cginc"
    VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); }
    VertexOutputForwardAdd vertAdd (VertexInput v) { return vertForwardAdd(v); }
	VertexOutputForwardBase vertBase_FurLayer(VertexInput v) { return vertForwardBase(v); }
	#if _MRT
		FragmentOutput fragBase (VertexOutputForwardBase i)  { return fragForwardBaseInternal(i); }
		//FragmentOutput fragAdd (VertexOutputForwardAdd i) { return fragForwardAddInternal(i); }
		FragmentOutput fragBase_FurLayer(VertexOutputForwardBase i) { return fragForwardBaseInternal(i); }
	#else
		half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i); }
		half4 fragBase_FurLayer(VertexOutputForwardBase i) : SV_Target{ return fragForwardBaseInternal(i); }
	#endif  
	
	half4 fragAdd (VertexOutputForwardAdd i) : SV_Target { return fragForwardAddInternal(i); }
	
    
#endif

#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED
