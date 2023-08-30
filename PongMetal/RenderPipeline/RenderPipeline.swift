//
//  RenderPipeline.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import Foundation
import Metal

class RenderPipeline
{
    let renderPipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState
    
    init(_ device: MTLDevice, _ shaderLib: ShaderLib)
    {
        let renderDescriptor = MTLRenderPipelineDescriptor()
        renderDescriptor.label = "render pipeline"
        renderDescriptor.vertexFunction = shaderLib.vertexFunction
        renderDescriptor.fragmentFunction = shaderLib.fragmentFunction
        renderDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderDescriptor.depthAttachmentPixelFormat = .depth32Float 
        
        // set descriptors
        
    
        guard let renderPipelineState = try? device.makeRenderPipelineState(descriptor: renderDescriptor) else {
            fatalError("Could not create render pipeline state")
        }
        
        self.renderPipelineState = renderPipelineState
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        
        guard let depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
          fatalError("Could not create depth stencil state")
        }
        
        self.depthStencilState = depthStencilState

    }
    
    func draw(
            renderEncoder: MTLRenderCommandEncoder,
            indexCount: Int,
            instanceCount: Int,
            geometryBuffers: GeometryBuffers,
            cameraBuffers: CameraBuffers,
            instanceBuffers: InstanceBuffers,
            lightBuffers: LightBuffers
    )
    {
        renderEncoder.setRenderPipelineState(renderPipelineState)
        
        renderEncoder.setVertexBuffer(geometryBuffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(geometryBuffers.normalBuffer, offset: 0, index: 1)
        
        renderEncoder.setVertexBuffer(cameraBuffers.perspectiveCameraBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(cameraBuffers.viewCameraBuffer, offset: 0, index: 3)
        
        renderEncoder.setVertexBuffer(instanceBuffers.transformBuffer, offset: 0, index: 4)
        renderEncoder.setVertexBuffer(instanceBuffers.normalBuffer, offset: 0, index: 5)
        renderEncoder.setVertexBuffer(instanceBuffers.diffuseColorBuffer, offset: 0, index: 6)
        
        renderEncoder.setVertexBuffer(lightBuffers.ambientLightBuffer, offset: 0, index: 7)
        renderEncoder.setVertexBuffer(lightBuffers.directionalLightDirectionBuffer, offset: 0, index: 8)
        renderEncoder.setVertexBuffer(lightBuffers.directionalLightColorBuffer, offset: 0, index: 9)
        
        renderEncoder.drawIndexedPrimitives(
            type: MTLPrimitiveType.triangle,
            indexCount: indexCount,
            indexType: MTLIndexType.uint16,
            indexBuffer: geometryBuffers.indexBuffer,
            indexBufferOffset: 0,
            instanceCount: instanceCount
        )
    }
}
