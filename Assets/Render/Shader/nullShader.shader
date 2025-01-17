// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Hidden/NullShader" {
Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("mainTex", 2D) = "white" {}
}

Category {
    //Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    //Blend SrcAlpha OneMinusSrcAlpha
    //ColorMask RGB
	ZTest Always
    Cull Off Lighting Off ZWrite Off

    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
			
			#pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _TintColor;
			
            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            float4 _MainTex_ST;

            v2f vert (appdata_t v)
            {
                v2f o = (v2f)0;               
                o.vertex = UnityObjectToClipPos(v.vertex); 
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);				
                return o;
            }            

            half4 frag (v2f i) : SV_Target
            {            
				clip(-0.5);
				half4 color = tex2D(_MainTex, i.texcoord);
                return color;
            }
            ENDCG
        }
    }
}
}
