//
//  LightBuffers.swift
//  PongMetal
//
//  Created by Luka Erkapic on 24.08.23.
//

import Foundation
import Metal
import simd

class LightBuffers
{
    private var _ambientLightBuffer: MTLBuffer
    private var _directionalLightDirectionBuffer: MTLBuffer
    private var _directionalLightColorBuffer: MTLBuffer
    
    var ambientLightBuffer: MTLBuffer { return _ambientLightBuffer }
    var directionalLightDirectionBuffer: MTLBuffer { return _directionalLightDirectionBuffer }
    var directionalLightColorBuffer: MTLBuffer { return _directionalLightColorBuffer }
    
    
    init(_ device: MTLDevice)
    {
        _ambientLightBuffer = device.makeBuffer( length: MemoryLayout<simd_float4>.stride, options: [])!
        _directionalLightDirectionBuffer = device.makeBuffer( length: MemoryLayout<simd_float3>.stride, options: [])!
        _directionalLightColorBuffer = device.makeBuffer( length: MemoryLayout<simd_float4>.stride, options: [])!
    }
 
    func writeIntoBuffers(ambientLight: inout AmbientLight, directionalLight: inout DirectionalLight)
    {
        _ambientLightBuffer
            .contents()
            .copyMemory(
                from: &ambientLight.color,
                byteCount: _ambientLightBuffer.length
            )
        
        _directionalLightDirectionBuffer
            .contents()
            .copyMemory(
                from: &directionalLight.direction,
                byteCount: _directionalLightDirectionBuffer.length
            )
        
        _directionalLightColorBuffer
            .contents()
            .copyMemory(
                from: &directionalLight.color,
                byteCount: _directionalLightColorBuffer.length
            )
    
    }
}
