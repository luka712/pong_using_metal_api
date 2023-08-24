//
//  InstanceBuffers.swift
//  PongMetal
//
//  Created by Luka Erkapic on 24.08.23.
//

import Foundation
import Metal
import simd

class InstanceBuffers
{
    private let _transformBuffer: MTLBuffer
    private let _normalBuffer: MTLBuffer
    private let _diffuseColroBuffer: MTLBuffer
    
    /*
     Get the transform/model buffer
     */
    var transformBuffer: MTLBuffer { return _transformBuffer }
    
    /*
     Get the normal buffer.
     3x3 matrix of transform matrix, with inverse.transpose.
     Used to transform normals in shader.
     */
    var normalBuffer: MTLBuffer { return _normalBuffer }
    
    /**
        Get the diffuse color buffer.
     */
    var diffuseColorBuffer: MTLBuffer { return _diffuseColroBuffer }
    

    init(_ device: MTLDevice, instances: Int )
    {
        _transformBuffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride * instances, options: [])!
        _normalBuffer = device.makeBuffer(length: MemoryLayout<simd_float3x3>.stride * instances, options: [])!
        _diffuseColroBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride * instances, options: [])!
    }
    
    /*
     Write the transform and normal matrices to buffers.
        @param instance: instance index
        @param transformMatrix: transform matrix
        @param normalMatrix: normal matrix
     */
    func writeToBuffers(instance: Int, transformMatrix: inout simd_float4x4, normalMatrix: inout simd_float3x3, diffuseColor: inout simd_float4)
    {
        _transformBuffer
            .contents()
            .advanced(by: MemoryLayout<simd_float4x4>.stride * instance) // offset
            .copyMemory(from: &transformMatrix, byteCount: MemoryLayout<simd_float4x4>.stride)
                
        _normalBuffer
            .contents()
            .advanced(by: MemoryLayout<simd_float3x3>.stride * instance) // offset
            .copyMemory(from: &normalMatrix, byteCount: MemoryLayout<simd_float3x3>.stride)
        
       _diffuseColroBuffer
            .contents()
            .advanced(by: MemoryLayout<simd_float4>.stride * instance) // offset
            .copyMemory(from: &diffuseColor, byteCount: MemoryLayout<simd_float4>.stride)
    }
}
