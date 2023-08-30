//
//  FxaaRenderPipeline.swift
//  PongMetal
//
//  Created by Luka Erkapic on 29.08.23.
//

import Foundation
import Metal

class FxaaRenderPipeline

{
    let renderPipelineState: MTLRenderPipelineState
    let buffers: GeometryBuffers
    let resolutionBuffer: MTLBuffer
    
    let destinationTexture: MTLTexture
    let sampler: MTLSamplerState
    
    
    
    init(_ device: MTLDevice)
    {
        let geometry = QuadGeometry();
        buffers = GeometryBuffers(device, geometry.indices, geometry.vertices, nil, geometry.uvCoords)
        let shaderLib = ShaderLib(device: device, vertexFnName: "fxaa_vs_main", fragmentFnName: "fxaa_fs_main")
        
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.label = "fxaa"
        renderDescriptor.vertexFunction = shaderLib.vertexFunction
        renderDescriptor.fragmentFunction = shaderLib.fragmentFunction
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // set descriptors
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderDescriptor) else {
            fatalError("Could not create render pipeline state")
        }
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.width = Int(GameSetup.gameWidth)
        textureDescriptor.height = Int(GameSetup.gameHeight)
        textureDescriptor.mipmapLevelCount = 1
        destinationTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        let resolution: [Float] = [ Float(GameSetup.gameWidth), Float(GameSetup.gameHeight)]
        resolutionBuffer = device.makeBuffer(bytes: resolution, length: MemoryLayout<Float>.size * 2, options: [])!
        
        
        
        self.renderPipelineState = renderPipelineState
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder)
    {
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(buffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(buffers.texCoordsBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(resolutionBuffer, offset: 0, index: 2)

        renderEncoder.setFragmentTexture(destinationTexture, index: 0)
        renderEncoder.setFragmentSamplerState(sampler, index: 0)
        
        renderEncoder.drawIndexedPrimitives(
            type: MTLPrimitiveType.triangle,
            indexCount: 6,
            indexType: MTLIndexType.uint16,
            indexBuffer: buffers.indexBuffer,
            indexBufferOffset: 0,
            instanceCount: 1
        )
    }
}
