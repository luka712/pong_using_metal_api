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
    
    // material
    float4 diffuseColor [[user(locn2)]];
    
    // lights
    float4 ambientLight [[user(locn3)]];
    float3 directionalLightDir [[user(locn4)]];
    float4 directionalLightColor [[user(locn5)]];

};

vertex VSOutput vs_main(
                        // attributes
                        const device packed_float3* a_position [[buffer(0)]],
                        const device packed_float3* a_normal [[buffer(1)]],
                        
                        // camera transform uniforms
                        constant float4x4 &projectionMatrix [[buffer(2)]],
                        constant float4x4 &viewMatrix [[buffer(3)]],
                        constant float4x4 *transformMatrix [[buffer(4)]],
                        constant float3x3 *normalMatrix [[buffer(5)]],
                        
                        // material
                        constant float4 *diffuseColor [[buffer(6)]],
                        
                        // lights
                        constant float4 &ambientLight [[buffer(7)]],
                        constant packed_float3 &directionalLightDir [[buffer(8)]],
                        constant float4 &directionalLightColor [[buffer(9)]],
                        
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
    out.diffuseColor = diffuseColor[iid];
    out.ambientLight = ambientLight;
    out.directionalLightDir = directionalLightDir;
    out.directionalLightColor = directionalLightColor;
    
    return out;
}

fragment float4 fs_main(VSOutput in [[stage_in]])
{
    float4 ambientFactor = in.diffuseColor * in.ambientLight;
    
    float3 normal = in.normal;
    
    float amount = max(dot(normal, -in.directionalLightDir), 0.0);
    float4 directionalFactor= in.diffuseColor * in.directionalLightColor * amount;
    
    return ambientFactor + directionalFactor;

}

