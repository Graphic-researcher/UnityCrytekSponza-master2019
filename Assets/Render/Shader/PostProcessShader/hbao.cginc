#ifndef HBAO_INCLUDED
#define HBAO_INCLUDED

#define NORMALS_RECONSTRUCT 0

static const float2 Directions[8] = {
    float2(1,0),
    float2(-0.5000001,0.8660254),
    float2(-0.4999999,-0.8660254),
	float2(0,1),
	float2(0,1),
	float2(0,1),
	float2(0,1),
	float2(0,1),	
};

half3 DecodeNormal (half2 enc)
{
    half2 fenc = enc*4-2;
    half f = dot(fenc,fenc);
    half g = sqrt(1-f/4);
    half3 n;
    n.xy = fenc*g;
    n.z = 1-f/2;
    return n;
}


//inline float3 FetchViewPos(float2 uv,float2 depth) {	
//	float z = DecodeFloatRG (depth) * _ProjectionParams.z;
//	return float3((uv * _UVToView.xy + _UVToView.zw) * z, z);
//}

inline float3 FetchViewPos(float2 uv) {	
	float z = DECODE_EYEDEPTH(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
	return float3((uv * _UVToView.xy + _UVToView.zw) * z, z);
}


inline float Falloff(float distanceSquare) {
	// 1 scalar mad instruction
	return distanceSquare * _NegInvRadius2 + 1.0;
}

inline float ComputeAO(float3 P, float3 N, float3 S) {
	float3 V = S - P;
	float VdotV = dot(V, V);
	VdotV = clamp(VdotV,0.01,10000); // fixed precision
	float NdotV = dot(N, V) * rsqrt(VdotV);

	//return saturate(Falloff(VdotV));
	// Use saturate(x) instead of max(x,0.f) because that is faster on Kepler
	return saturate(NdotV - _AngleBias) * saturate(Falloff(VdotV));
}

inline float3 MinDiff(float3 P, float3 Pr, float3 Pl) {
	float3 V1 = Pr - P;
	float3 V2 = P - Pl;
	return (dot(V1, V1) < dot(V2, V2)) ? V1 : V2;
}

inline float2 RotateDirections(float2 dir, float2 rot) {
	return float2(dir.x * rot.x - dir.y * rot.y,
					dir.x * rot.y + dir.y * rot.x);
}


half4 frag_ao(v2f i, UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target {

	

	//float3 P = FetchViewPos(i.uv2,depthNormal.zw);
	float3 P = FetchViewPos(i.uv2);//当前点

	clip(_MaxDistance - P.z);
	
	float stepSize = min((_AORadius / P.z), 128) / (STEPS + 1.0);//光线步进步长

	// (cos(alpha), sin(alpha), jitter)
	float3 rand = tex2D(_NoiseTex, screenPos.xy / 4.0).rgb;

	float2 InvScreenParams = _ScreenParams.zw - 1.0;
	
#if NORMALS_RECONSTRUCT
		float3 Pr, Pl, Pt, Pb;
		Pr = FetchViewPos(i.uv2 + float2(InvScreenParams.x, 0));
		Pl = FetchViewPos(i.uv2 + float2(-InvScreenParams.x, 0));
		Pt = FetchViewPos(i.uv2 + float2(0, InvScreenParams.y));
		Pb = FetchViewPos(i.uv2 + float2(0, -InvScreenParams.y));
		float3 N = normalize(cross(MinDiff(P, Pr, Pl), MinDiff(P, Pt, Pb)));
#else
	float4 normal = tex2D(_NormalBufferTex, i.uv2);
	float3 N = DecodeNormal(normal.xy);
	//float3 N = mul((float3x3)(UNITY_MATRIX_I_V),viewNormal);	
	//float3 N = normal * 2 - 1;
#endif	

	N = float3(N.x, -N.yz);

	float ao = 0;

	UNITY_UNROLL
	for (int d = 0; d < DIRECTIONS; ++d) {//对各方向
		float2 direction = RotateDirections(Directions[d], rand.xy);//随机旋转角度

		// Jitter starting sample within the first step
		float rayPixels = (rand.z * stepSize + 1.0);

		UNITY_UNROLL
		for (int s = 0; s < STEPS; ++s) {//进行光线步进

			float2 snappedUV = round(rayPixels * direction) * InvScreenParams  + i.uv2;
			
			//float4 depthNormal2 = tex2D(_CameraDepthNormalsTexture, snappedUV);
			
			//float3 S = FetchViewPos(snappedUV,depthNormal2.zw);
			float3 S = FetchViewPos(snappedUV);

			rayPixels += stepSize;

			float contrib = ComputeAO(P, N, S);
			ao += contrib;

		}
	}
		
	ao *= (_AOmultiplier / (STEPS * DIRECTIONS));

	ao = saturate(1.0 - ao);//衰减公式,解决AO差值过大的不连续问题
	
	return half4(ao, 0,0,1);
}

#endif // HBAO_INCLUDED
