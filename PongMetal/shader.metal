//
//  shader.metal
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

#include <metal_stdlib>
using namespace metal;


struct VSOutput
{
    float4 position [[position]];
    float3 normal [[user(locn0)]];
    float3 fragmentPosition [[user(locn1)]];
};

vertex VSOutput vs_main(
                        // attributes
                        const device packed_float3* a_position [[buffer(0)]],
                        const device packed_float3* a_normal [[buffer(1)]],
                        
                        // uniforms
                        constant float4x4 &projectionMatrix [[buffer(2)]],
                        constant float4x4 &viewMatrix [[buffer(3)]],
                        constant float4x4 *transformMatrix [[buffer(4)]],
                        constant float3x3 *normalMatrix [[buffer(5)]],
                        
                        // built in
                        uint vid [[vertex_id]],
                        uint iid [[instance_id]])
{
    VSOutput out;
    float4 pos = float4(a_position[vid], 1.0);
    float4x4 modelMatrix = transformMatrix[iid];
    float4 fragPos = modelMatrix * pos;
    
    out.position = projectionMatrix * viewMatrix * fragPos;
    out.normal = normalize(normalMatrix[iid] * a_normal[vid].xyz);
    out.fragmentPosition = fragPos.xyz;
    
    return out;
}

fragment float4 fs_main(VSOutput in [[stage_in]])
{
    float3 dirLightDir = normalize(float3(0.0, -1.0, 0.0));
    float3 normal = in.normal;
    
    float amount = max(dot(normal, -dirLightDir), 0.0);
    float4 diffuse = float4(1.0, 1.0, 1.0, 1.0) * amount;
    
    
    return float4(0.4, 0.4, 0.4, 1.0) * diffuse;
}

