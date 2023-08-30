//
//  shader_fxaa.metal
//  PongMetal
//
//  Created by Luka Erkapic on 29.08.23.
//
// Reading
// http://blog.simonrodriguez.fr/articles/2016/07/implementing_fxaa.html
// https://catlikecoding.com/unity/tutorials/advanced-rendering/fxaa/
// https://developer.download.nvidia.com/assets/gamedev/files/sdk/11/FXAA_WhitePaper.pdf
// https://github.com/bartwronski/CSharpRenderer/blob/master/shaders/FXAA.hlsl

#include <metal_stdlib>
using namespace metal;

/**
 The minimum amount of local contrast required to apply algorithm.
 1/3 – too little
 1/4 – low quality
 1/8 – high quality
 1/16 – overkill
 */
#define FXAA_EDGE_THRESHOLD (1.0/8.0)

/**
 Trims the algorithm from processing darks.
 1/32 – visible limit
 1/16 – high quality
 1/12 – upper limit (start of visible unfiltered edges)
 */
#define FXAA_EDGE_THRESHOLD_MIN (1.0/16.0)

/**
 Controls removal of sub-pixel aliasing.
 1/2 – low removal
 1/3 – medium removal
 1/4 – default removal
 1/8 – high removal
 0 – complete removal
 */
#define FXAA_SUBPIX_TRIM (1.0/4.0)

#define NO_COLOR true

#define DEBUG_LUMINANCE false
#define DEBUG_CONTRAST false
#define DEBUG_EDGE false // will be red color
#define DEBUG_CONTRAST_RATIO false
#define DEBUG_EDGE_VERTICAL false
#define DEBUG_EDGE_HORIZONTAL true

struct VSOutput
{
    float4 position [[position]];
    float2 texCoords [[user(locn0)]];
    float2 screenResolution [[user(locn1)]];

};

vertex VSOutput fxaa_vs_main(
                        // attributes
                        const device packed_float3* a_position [[buffer(0)]],
                        const device packed_float2* a_texCoords [[buffer(1)]],
                    
                        // constants
                        constant float2& screenResolution [[buffer(2)]],
                        
                        
                        // built in
                        uint vid [[vertex_id]],
                        uint iid [[instance_id]])
{
    VSOutput out;
    float4 pos = float4(a_position[vid], 1.0);
    out.position = pos;
    out.texCoords = a_texCoords[vid];
    out.screenResolution = screenResolution;
    
    return out;
}

float luma(float3 rgb)
{
    // get luminance and correct for gamma!
    float l = dot(rgb,  float3(0.299, 0.587, 0.114));
    return sqrt(l);
}

struct TextureOffsetInput
{
    texture2d<float, access::sample> texture;
    sampler sampler;
    float2 uv;
    float2 screenResolution;
};

/**
 Return the offset from pixel offset.
 Offset is given in pixel, for example pixel left of is (-1, 0)
 
 */
float3 textureOffset(TextureOffsetInput input, float2 offset)
{
    float2 o = float2(offset.x / input.screenResolution.x, offset.y / input.screenResolution.y);
    return input.texture.sample(input.sampler, input.uv + o).rgb;
}

/**
 Min value of 5 values
 */
float min5(float a, float b, float c, float d, float e)
{
    return min(a, min(b, min(c, min(d, e))));
}

/**
    Max value of 5 values
 */
float max5(float a, float b, float c, float d, float e)
{
    return max(a, max(b, max(c, max(d, e))));
}


fragment float4 fxaa_fs_main(VSOutput in [[stage_in]],
                        texture2d<float, access::sample> texture [[texture(0)]],
                        sampler sampler [[sampler(0)]]
                        )
{
    // placeholder
    TextureOffsetInput texOffsetInput;
    texOffsetInput.texture = texture;
    texOffsetInput.sampler = sampler;
    texOffsetInput.uv = in.texCoords;
    texOffsetInput.screenResolution = in.screenResolution;
    
    // Local Contrast Check
    // neighbor pixels
    float3 pixelLeft = textureOffset(texOffsetInput, float2(-1.0, 0.0));
    float3 pixelRight = textureOffset(texOffsetInput, float2(1.0, 0.0));
    float3 pixelCenter = textureOffset(texOffsetInput, float2(0.0,0.0));
    float3 pixelTop = textureOffset(texOffsetInput, float2(0.0, -1.0));
    float3 pixelBottom = textureOffset(texOffsetInput, float2(0.0, 1.0));
    
    // luma of the neighbor pixels
    float lumaLeft = luma(pixelLeft);
    float lumaRight = luma(pixelRight);
    float lumaCenter = luma(pixelCenter);
    float lumaTop = luma(pixelTop);
    float lumaBottom = luma(pixelBottom);
    
#if DEBUG_LUMINANCE
    return float4(lumaCenter, lumaCenter, lumaCenter, 1.0);
#endif
    
    // If the difference in local maximum and minimum luma (contrast) is
    // lower than a threshold proportional to the maximum local luma, then the shader
    // early exits (no visible aliasing). This threshold is clamped at a minimum value to
    //  avoid processing in really dark areas.
    float contrastMin = min5(lumaCenter, lumaTop, lumaRight, lumaBottom, lumaLeft);
    float contrastMax = max5(lumaCenter, lumaTop, lumaRight, lumaBottom, lumaLeft);
    float localContrast = contrastMax - contrastMin;
    
#if DEBUG_CONTRAST
    return float4(localContrast, localContrast, localContrast, 1.0);
#endif
    
    // do nothing if contrast is too low, there is no aliasing
    if(localContrast < max(FXAA_EDGE_THRESHOLD_MIN, contrastMax * FXAA_EDGE_THRESHOLD))
    {
#if NO_COLOR
        return float4(0.0, 0.0, 0.0, 1.0);
#endif
        return float4(pixelCenter, 1.0);
    }
    
#if DEBUG_EDGE
    return float4(1.0, 0.0, 0.0, 1.0);
#endif
    
    // Sub-pixel Aliasing Test
    /**
     Pixel contrast is estimated as the absolute difference in pixel luma from a lowpass
     luma (computed as the average of the North, South, East and West neighbors). The
     ratio of pixel contrast to local contrast is used to detect sub-pixel aliasing. This ratio
     approaches 1.0 in the presence of single pixel dots and otherwise begins to fall off
     towards 0.0 as more pixels contribute to an edge. The ratio is transformed into the
     amount of lowpass filter to blend in at the end of the algorithm.
     */
    float lowpassLuma = (lumaTop + lumaBottom + lumaLeft + lumaRight) / 4.0; // or average surrounding pixels brightness
    // Calculate the contrast between the average neighbor brightness and the current pixel brightness
    float lumaRange = abs(lowpassLuma - localContrast); //
    // Calculate the ratio of pixel contrast to local contrast
    float contrastRatio = lumaRange / localContrast;
    
#if DEBUG_CONTRAST_RATIO
    return float4(contrastRatio, contrastRatio, contrastRatio, 1.0);
#endif
    
    // get rest of the neighbor pixels
    float3 pixelLeftTop = textureOffset(texOffsetInput, float2(-1.0, -1.0));
    float3 pixelRightTop = textureOffset(texOffsetInput, float2(1.0, -1.0));
    float3 pixelLeftBottom = textureOffset(texOffsetInput, float2(-1.0, 1.0));
    float3 pixelRightBottom = textureOffset(texOffsetInput, float2(1.0, 1.0));
    
    float lumaLeftTop = luma(pixelLeftTop);
    float lumaRightTop = luma(pixelRightTop);
    float lumaLeftBottom = luma(pixelLeftBottom);
    float lumaRightBottom = luma(pixelRightBottom);
    
    
    // Vertical/Horizontal Edge Test
    /**
     Edge detect filters like Sobel fail on single pixel lines which pass through the center
     of a pixel. FXAA takes a weighted average magnitude of the high-pass values for
     rows and columns of the local 3x3 neighborhood as an indication of local edge
     amount.
     */
    // factor is lower depending on distance from center
    float edgeVertical = abs(0.25* lumaLeftTop          + -0.5 * lumaTop            + 0.25 * lumaRightTop) +
                        abs(0.5 * lumaLeft              + -1.0 * lumaCenter         + 0.5 * lumaRight) +
                        abs(0.25 * lumaLeftBottom       + -0.5 * lumaBottom         + 0.25 * lumaRightBottom);
    
    float edgeHorizontal = abs(0.25 * lumaLeftTop        + -0.5 * lumaLeft           + 0.25 * lumaLeftBottom) +
                        abs(0.5 * lumaTop               + -1.0 * lumaCenter         + 0.5 * lumaBottom) +
                        abs(0.25 * lumaRightTop         + -0.5 * lumaRight          + 0.25 * lumaRightBottom);
    
#if DEBUG_EDGE_VERTICAL
    return float4(edgeVertical, edgeVertical, edgeVertical, 1.0);
#endif
#if DEBUG_EDGE_HORIZONTAL
    return float4(edgeHorizontal, edgeHorizontal, edgeHorizontal, 1.0);
#endif
    
    bool horzDirection = edgeHorizontal >= edgeVertical;
    
    // Choosing edge orientation
    /**
     The current pixel is not necessarily exactly on the edge. The next step is thus to determine in which orientation, orthogonal to the edge direction, is the real edge border.
     The gradient on each side of the crrent pixel is computed, and where it is the steepest probably lies the edge border.
     */
    
    // Select the two neighboring texels lumas in the opposite direction to the local edge.
    // so if horizontal we care about the top and bottom neighbors
    // if vertical we care about the left and right neighbors
    float texel1 = horzDirection ? lumaBottom : lumaLeft;
    float texel2 = horzDirection ? lumaTop : lumaRight;
    
    // compute gradients in the opposite direction to the local edge
    float gradient1 = texel1 - lumaCenter;
    float gradient2 = texel2 - lumaCenter;
    
    // which direction is steepest
    bool is1Steepest = abs(gradient1) >= abs(gradient2);
    
    // gradients are normalized by the local contrast
    float localGradient = 0.25 * max(abs(gradient1), abs(gradient2));
    

    return float4(pixelCenter.xyz, 0.0);
}
