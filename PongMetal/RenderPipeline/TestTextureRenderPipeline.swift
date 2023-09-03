//
//  TestTextureRenderPipeline.swift
//  PongMetal
//
//  Created by Luka Erkapic on 01.09.23.
//

import Foundation
import Metal
import MetalKit

class TestTextureRenderPipeline
{
    let renderPipelineState: MTLRenderPipelineState
    let buffers: GeometryBuffers
    var texture: MTLTexture? = nil
    
    let destinationTexture: MTLTexture
    let sampler: MTLSamplerState
    
    init(_ device: MTLDevice)
    {
        let geometry = QuadGeometry();
        buffers = GeometryBuffers(device, geometry.indices, geometry.vertices, nil, geometry.uvCoords)
        let shaderLib = ShaderLib(device: device, vertexFnName: "internal_res_vs_main", fragmentFnName: "internal_res_fs_main") // these can be used, since they're simple enough
        
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.label = "internal resolution"
        renderDescriptor.vertexFunction = shaderLib.vertexFunction
        renderDescriptor.fragmentFunction = shaderLib.fragmentFunction
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderDescriptor.depthAttachmentPixelFormat = .depth32Float
        
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
        
        self.renderPipelineState = renderPipelineState
        
        guard let textureFile = Bundle.main.path(forResource: "test", ofType: "png") else {
            print("Texture 'test.png' file not found!")
            return
        }
        
        let textureLoader = MTKTextureLoader(device: device)
        do {
            self.texture = try textureLoader.newTexture(URL: URL(filePath: textureFile), options: [
                .origin: MTKTextureLoader.Origin.topLeft,
            ])
        } catch {
            fatalError("Could not load texture 'test.png'")
        }
    }
    
    func draw(renderEncoder: MTLRenderCommandEncoder)
    {
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(buffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(buffers.texCoordsBuffer, offset: 0, index: 1)
        
        renderEncoder.setFragmentTexture(texture, index: 0)
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
