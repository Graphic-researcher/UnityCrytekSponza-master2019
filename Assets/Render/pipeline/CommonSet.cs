using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using UnityEngine.Events;

public class CommonSet : MonoBehaviour{

    #region fullscreenTriangle
    static Mesh s_FullscreenTriangle;    
    public static Mesh fullscreenTriangle
    {
        get
        {
            if (s_FullscreenTriangle != null)
                return s_FullscreenTriangle;

            s_FullscreenTriangle = new Mesh { name = "Fullscreen Triangle" };

            // Because we have to support older platforms (GLES2/3, DX9 etc) we can't do all of
            // this directly in the vertex shader using vertex ids :(
            s_FullscreenTriangle.SetVertices(new List<Vector3>
                {
                    new Vector3(-1f, -1f, 0f),
                    new Vector3(-1f,  3f, 0f),
                    new Vector3( 3f, -1f, 0f)
                });
            s_FullscreenTriangle.SetIndices(new[] { 0, 1, 2 }, MeshTopology.Triangles, 0, false);
            s_FullscreenTriangle.UploadMeshData(false);

            return s_FullscreenTriangle;
        }
    }

    static Mesh s_SmallscreenTriangle;
    public static Mesh smallscreenTriangle
    {
        get
        {
            if (s_SmallscreenTriangle != null)
                return s_SmallscreenTriangle;

            s_SmallscreenTriangle = new Mesh { name = "Smallscreen Triangle" };

            // Because we have to support older platforms (GLES2/3, DX9 etc) we can't do all of
            // this directly in the vertex shader using vertex ids :(
            s_SmallscreenTriangle.SetVertices(new List<Vector3>
                {
                    new Vector3(-0.1f, -0.1f, 0f),
                    new Vector3(-0.1f,  0.3f, 0f),
                    new Vector3( 0.3f, -0.1f, 0f)
                });
            s_SmallscreenTriangle.SetIndices(new[] { 0, 1, 2 }, MeshTopology.Triangles, 0, false);
            s_SmallscreenTriangle.UploadMeshData(false);

            return s_SmallscreenTriangle;
        }
    }
    #endregion

    #region shaderProperties
    public static class ShaderProperties
    {
        public static int sceneTex = Shader.PropertyToID("_SceneTex");
        public static int alphaTex = Shader.PropertyToID("_AlphaTex");
        public static int distortionTex = Shader.PropertyToID("_DistortionTex");
        public static int sceneCopyTex = Shader.PropertyToID("_SceneCopyTex");

        public static int aoBlurXTex = Shader.PropertyToID("_AOBlurXTex");
        public static int aoBlurYTex = Shader.PropertyToID("_AOBlurYTex");
        public static int hbaoTex = Shader.PropertyToID("_HBAOTex");
        public static int noiseTex = Shader.PropertyToID("_NoiseTex");
        public static int uvToView = Shader.PropertyToID("_UVToView");
        public static int aoRadius = Shader.PropertyToID("_AORadius");
        public static int maxDistance = Shader.PropertyToID("_MaxDistance");
        public static int negInvRadius2 = Shader.PropertyToID("_NegInvRadius2");
        public static int angleBias = Shader.PropertyToID("_AngleBias");
        public static int aoMultiplier = Shader.PropertyToID("_AOmultiplier");
        public static int aoIntensity = Shader.PropertyToID("_AOIntensity");
        public static int aoColor = Shader.PropertyToID("_AOColor");
        public static int aoBlurOffset = Shader.PropertyToID("_AoBlurOffset");

        public static int bloomIntensity = Shader.PropertyToID("_BloomIntensity");
        public static int bloomCurve = Shader.PropertyToID("_BloomCurve");
        public static int playerBloomIntensity = Shader.PropertyToID("_PlayerBloomIntensity");       
        public static int playerBloomCurve = Shader.PropertyToID("_PlayerBloomCurve");
        public static int alphaBloomIntensity = Shader.PropertyToID("_AlphaBloomIntensity");

        public static int bloomThresholdTex = Shader.PropertyToID("_BloomThresholdTex");
        public static int bloomBlurTex = Shader.PropertyToID("_BloomBlurTex");
        public static int bloomDownSampleTex = Shader.PropertyToID("_BloomDownSampleTex");
        public static int bloomScale = Shader.PropertyToID("_BloomScale");
        public static int bloomTex = Shader.PropertyToID("_BloomTex");
        public static int playerBloomTex = Shader.PropertyToID("_PlayerBloomTex");
        public static int alphaBloomTex = Shader.PropertyToID("_AlphaBloomTex");
        public static int bloomTempTex = Shader.PropertyToID("_BloomTempTex");
        public static int[] blurTexArray1 = new int[] { Shader.PropertyToID("_BlurTex1"),Shader.PropertyToID("_BlurTex2"),Shader.PropertyToID("_BlurTex3"),Shader.PropertyToID("_BlurTex4"),
            Shader.PropertyToID("_BlurTex5"),Shader.PropertyToID("_BlurTex6"),Shader.PropertyToID("_BlurTex7"),Shader.PropertyToID("_BlurTex8")};
        public static int[] blurTexArray2 = new int[] { Shader.PropertyToID("_BlurTex11"),Shader.PropertyToID("_BlurTex12"),Shader.PropertyToID("_BlurTex13"),Shader.PropertyToID("_BlurTex14"),
            Shader.PropertyToID("_BlurTex15"),Shader.PropertyToID("_BlurTex16"),Shader.PropertyToID("_BlurTex17"),Shader.PropertyToID("_BlurTex18")};

        public static int depthOfFieldParams = Shader.PropertyToID("_DepthOfFieldParams");
        public static int cocTex = Shader.PropertyToID("_CoCTex");
        public static int depthOfFieldTex = Shader.PropertyToID("_DepthOfFieldTex");
        public static int dofTempTex = Shader.PropertyToID("_DofTempTex");
        public static int sceneWithAlphaTex = Shader.PropertyToID("_SceneWithAlphaTex");

        public static int userLutParams = Shader.PropertyToID("_UserLutParams");
        public static int userLutTex = Shader.PropertyToID("_UserLutTex");
        public static int whiteBalance = Shader.PropertyToID("_WhiteBalance");
        public static int colorFilter = Shader.PropertyToID("_ColorFilter");
        public static int lift = Shader.PropertyToID("_Lift");
        public static int invGamma = Shader.PropertyToID("_InvGamma");
        public static int gain = Shader.PropertyToID("_Gain");
        public static int hsc = Shader.PropertyToID("_HSC");
        public static int channelMixerRed = Shader.PropertyToID("_ChannelMixerRed");
        public static int channelMixerGreen = Shader.PropertyToID("_ChannelMixerGreen");
        public static int channelMixerBlue = Shader.PropertyToID("_ChannelMixerBlue");
        public static int curveTex = Shader.PropertyToID("_CurveTex");   
        public static int lutParams = Shader.PropertyToID("_LutParams");
        public static int sceneLutTex = Shader.PropertyToID("_SceneLutTex");
        public static int playerLutTex = Shader.PropertyToID("_PlayerLutTex");
        public static int alphaLutTex = Shader.PropertyToID("_AlphaLutTex");
        public static int customToneCurve = Shader.PropertyToID("_CustomToneCurve");
        public static int toeSegmentA = Shader.PropertyToID("_ToeSegmentA");
        public static int toeSegmentB = Shader.PropertyToID("_ToeSegmentB");
        public static int midSegmentA = Shader.PropertyToID("_MidSegmentA");
        public static int midSegmentB = Shader.PropertyToID("_MidSegmentB");
        public static int shoSegmentA = Shader.PropertyToID("_ShoSegmentA");
        public static int shoSegmentB = Shader.PropertyToID("_ShoSegmentB");

        public static int loThreshold = Shader.PropertyToID("_LoThreshold");
        public static int loRadius = Shader.PropertyToID("_LoRadius");
        public static int loIntensity = Shader.PropertyToID("_LoIntensity");
        public static int loParams = Shader.PropertyToID("_LumaParams");
        public static int lumaBlurX = Shader.PropertyToID("_LumaBlurX");
        public static int lumaBlurY = Shader.PropertyToID("_LumaBlurY");
        public static int lumaTex = Shader.PropertyToID("_LumaTex");

        public static int adaptedLum = Shader.PropertyToID("_AdaptedLum");
        public static int alphaAdaptedLum = Shader.PropertyToID("_AlphaAdaptedLum");
        public static int playerAdaptedLum = Shader.PropertyToID("_PlayerAdaptedLum");

        public static int overlayTex = Shader.PropertyToID("_OverlayTex");
        public static int overlayColor = Shader.PropertyToID("_OverlayColor");

        public static int clipToWorld = Shader.PropertyToID("_ClipToWorld");

        public static int fogClipDir = Shader.PropertyToID("_FogClipDir");
        public static int volumetricFogColor = Shader.PropertyToID("_FogColor");
        public static int fogStep = Shader.PropertyToID("_FogStep");
        public static int fogDistance = Shader.PropertyToID("_FogDistance");
        public static int fogData = Shader.PropertyToID("_FogData");
        public static int fogNoiseTex = Shader.PropertyToID("_FogNoiseTex");
        public static int fogWindDir = Shader.PropertyToID("_FogWindDir");
        public static int fogJitter = Shader.PropertyToID("_FogJitter");
        public static int fogSunDir = Shader.PropertyToID("_FogSunDir");
        public static int fogSunColor = Shader.PropertyToID("_FogSunColor");
        public static int downSampleFogTex = Shader.PropertyToID("_DownSampleFogTex");
        public static int downSampleRawDepthTex = Shader.PropertyToID("_DownSampleRawDepthTex");
        public static int downSampleDepth = Shader.PropertyToID("_DownSampleDepth");

        public static int heightFogColor = Shader.PropertyToID("_HeightFogColor");
        public static int heightFogEmissionColor = Shader.PropertyToID("_HeightFogEmissionColor");
        public static int heightFogParam = Shader.PropertyToID("_HeightFogParam");
        public static int heightFogWave0 = Shader.PropertyToID("_HeightFogWave0");
        public static int heightFogWave1 = Shader.PropertyToID("_HeightFogWave1");      

        public static int vignetteColor = Shader.PropertyToID("_VignetteColor");
        public static int vignetteParam = Shader.PropertyToID("_VignetteParam");

        public static int borderColor = Shader.PropertyToID("_BorderColor");
        public static int borderParam = Shader.PropertyToID("_BorderParam");
        public static int borderTile = Shader.PropertyToID("_BorderTile");
        public static int borderTex = Shader.PropertyToID("_BorderTex");
        public static int borderMask = Shader.PropertyToID("_BorderMask");

        public static int radialAmount = Shader.PropertyToID("_RadialAmount");
        public static int radialStrength = Shader.PropertyToID("_RadialStrength");

        public static int cloudShadowTex = Shader.PropertyToID("_CloudShadowTex");
        public static int cloudShadowParams = Shader.PropertyToID("_CloudShadowParams");
        public static int cloudShadowColor = Shader.PropertyToID("_CloudShadowColor");

        public static int chromaAmount = Shader.PropertyToID("_ChromaAmount");
        public static int colorOffset = Shader.PropertyToID("_ColorOffset");

        public static int uberTex = Shader.PropertyToID("_UberTex");
        public static int rBlurTex = Shader.PropertyToID("_RBlurTex");

        public static int simpleCopyTex = Shader.PropertyToID("_SimpleCopyTex");

        public static int cameraDepthTex = Shader.PropertyToID("_CameraDepthTexture");
        public static int normalBufferTex = Shader.PropertyToID("_NormalBufferTex");
        public static int specBufferTex = Shader.PropertyToID("_SpecBufferTex");

        public static int hiZbufferTex = Shader.PropertyToID("_HiZbufferTex");
        public static int hiZbufferLevel = Shader.PropertyToID("_HiZbufferLevel");
        public static int rayCastTex0 = Shader.PropertyToID("_RayCastTex0");
        public static int rayCastTex1 = Shader.PropertyToID("_RayCastTex1");
        public static int rayCastTexDepth = Shader.PropertyToID("_RayCastDepth");
        public static int rayCastSize = Shader.PropertyToID("_RayCastSize");
        public static int ssrReflectionSize = Shader.PropertyToID("_SSRReflectionSize");
        public static int spatialTex = Shader.PropertyToID("_SpatialTex");
        public static int prevTemporalTex = Shader.PropertyToID("_PrevTemporalTex");
        public static int temporalTex = Shader.PropertyToID("_TemporalTex");     
        public static int rayNum = Shader.PropertyToID("_RayNum");
        public static int rayCastStepNum = Shader.PropertyToID("_RayCastStepNum");
        public static int hiZMaxLevel = Shader.PropertyToID("_HiZMaxLevel");
        public static int resolverNum = Shader.PropertyToID("_ResolverNum");
        public static int ssrMaxDistance = Shader.PropertyToID("_SSRMaxDistance");
        public static int brdfBias = Shader.PropertyToID("_BRDFBias");
        public static int rayCastThickness = Shader.PropertyToID("_RayCastThickness");
        public static int screenFade = Shader.PropertyToID("_ScreenFade");
        public static int temporalScale = Shader.PropertyToID("_TemporalScale");
        public static int temporalWeight = Shader.PropertyToID("_TemporalWeight");
        public static int smoothnessStrength = Shader.PropertyToID("_SmoothnessStrength");
        public static int specularStrength = Shader.PropertyToID("_SpecularStrength");
        public static int ssrNoiseTex = Shader.PropertyToID("_SSRNoiseTex");
        public static int ssrPreintegratedTex = Shader.PropertyToID("_SSRPreintegratedTex");
        public static int noiseSizeJitter = Shader.PropertyToID("_NoiseSizeJitter");
        public static int ssrProjectionMatrix = Shader.PropertyToID("_SSRProjectionMatrix");
        public static int ssrProjectionMatrixInverse = Shader.PropertyToID("_SSRProjectionMatrixInverse");
        public static int currViewProjectionMatrix = Shader.PropertyToID("_CurrViewProjectionMatrix");
        public static int prevViewProjectionMatrix = Shader.PropertyToID("_PrevViewProjectionMatrix");
    }
    #endregion 
   
    public static bool IsSupported()
    {
        Shader shader = Shader.Find("Hidden/DragonPostProcess");
        if (shader == null || !shader.isSupported)
        {
            Debug.LogError("Missing shader for image effect");
            return false;
        }

        return true;
    }

    public static RenderTextureFormat SelectFormat(RenderTextureFormat primary, RenderTextureFormat secondary)
    {
        if (SystemInfo.SupportsRenderTextureFormat(primary)) return primary;
        if (SystemInfo.SupportsRenderTextureFormat(secondary)) return secondary;
        return RenderTextureFormat.Default;
    }

    public static void CreateMaterial(String name,ref Material material)
    {
        if (material == null)
        {
            Shader shader = Shader.Find(name);
            if (shader && shader.isSupported)
            {
                material =  new Material(shader);
            }
        }
    }

    public static void DeleteMaterial(ref Material material)
    {
        if (material)
        {
#if UNITY_EDITOR
            DestroyImmediate(material);
#else
            Destroy(material);
#endif
            material = null;
        }
    }

    public static void DeleteRenderTexture(ref RenderTexture renderTex)
    {
        if (renderTex)
        {
            renderTex.Release();
            
#if UNITY_EDITOR
            DestroyImmediate(renderTex);
#else
            Destroy(renderTex);
#endif
            renderTex = null;
        }
    }

    public static void DeleteTexture(ref Texture2D Tex)
    {
        if (Tex)
        {
#if UNITY_EDITOR
            DestroyImmediate(Tex);
#else
            Destroy(Tex);
#endif
            Tex = null;
        }
    }

    public static void ClearCommandBuffer(Camera cam,ref CommandBuffer buffer,CameraEvent camEvent)
    {
        if(buffer != null)
        {
            if (cam)
                cam.RemoveCommandBuffer(camEvent, buffer);
            buffer.Clear();
        }
    }

    public static void SetMaterialKeyword(ref Material material,string keyword, bool enable)
    {
        if (material == null)
            return;

        if (enable)
        {
            material.EnableKeyword(keyword);
        }
        else
        {
            material.DisableKeyword(keyword);
        }
    }

    public static void RefreshRT(ref RenderTexture rt, int width,int height,int depth, RenderTextureFormat format,bool useMipMap,bool autoGenerateMips, FilterMode filterMode,ref bool forceUpdate,ref Camera cam)
    {
        if (rt)
        {
            if (width != rt.width || height != rt.height || rt.format != format || rt.depth != depth)
            {
                cam.targetTexture = null;
                CommonSet.DeleteRenderTexture(ref rt);
            }
        }
        if (!rt)
        {
            rt = new RenderTexture(width, height, depth, format, RenderTextureReadWrite.Linear);
            rt.autoGenerateMips = autoGenerateMips;
            rt.useMipMap = useMipMap;
            rt.filterMode = filterMode;
            forceUpdate = true;
        }
    }
}
