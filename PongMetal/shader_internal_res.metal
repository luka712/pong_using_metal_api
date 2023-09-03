//
//  shader_internal_res.metal
//  PongMetal
//
//  Created by Luka Erkapic on 29.08.23.
//


#include <metal_stdlib>
using namespace metal;


struct VSOutput
{
    float4 position [[position]];
    float2 texCoords [[user(locn0)]];
};

vertex VSOutput internal_res_vs_main(
                        // attributes
                        const device packed_float3* a_position [[buffer(0)]],
                        const device packed_float2* a_texCoords [[buffer(1)]],
                                            
                        // built in
                        uint vid [[vertex_id]],
                        uint iid [[instance_id]])
{
    VSOutput out;
    float4 pos = float4(a_position[vid], 1.0);
    out.position = pos;
    out.texCoords = a_texCoords[vid];
    
    return out;
}


fragment float4 internal_res_fs_main(VSOutput in [[stage_in]],
                        texture2d<float, access::sample> texture [[texture(0)]],
                        sampler sampler [[sampler(0)]]
                        )
{
    return texture.sample(sampler, in.texCoords);
}
