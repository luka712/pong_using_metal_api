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
}
