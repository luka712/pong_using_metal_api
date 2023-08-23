//
//  Coordinator.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import Foundation
import MetalKit


class Coordinator : NSObject, MTKViewDelegate {

    let width: CGFloat
    let height: CGFloat
    
    var camera: Camera
    
    // paddles
    let paddle1 = Paddle(position: simd_float3(0,0,0))
    let paddle2 = Paddle(position: simd_float3(0,0,-10))
    let paddleRenderPipeline: RenderPipeline
    let paddleTransformBuffers: MTLBuffer
    let paddleNormalBuffers: MTLBuffer
    let paddleBuffers: Buffers

    // ball
    let ball = Ball(position: simd_float3(0.0,0.0,0.0))
    let ballRenderPipeline: RenderPipeline
    let ballTransformBuffer: MTLBuffer
    let ballNormalBuffer: MTLBuffer
    let ballBuffers: Buffers
    let countOfBallIndices: Int
    
    
    let device: MTLDevice
    let shaderLib: ShaderLib

    let cameraBuffers: CameraBuffers
    
    
    init(width: CGFloat = 1280.0, height:CGFloat = 720.0 )
    {
        self.width = width
        self.height = height
    
        self.camera = Camera(width,height)
        
        device = MTLCreateSystemDefaultDevice()!
        shaderLib = ShaderLib(device: device)
        
        cameraBuffers = CameraBuffers(device)
        
        // setup paddles
        paddleRenderPipeline = RenderPipeline(device, shaderLib)
        let cubeGeometry = CubeGeometry();
        paddleBuffers = Buffers(device, cubeGeometry.indices, cubeGeometry.positionVertices, cubeGeometry.normalVertices)
        paddleTransformBuffers = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride * 2, options: [])!
        paddleNormalBuffers = device.makeBuffer(length: MemoryLayout<simd_float3x3>.stride * 2, options: [])!
        
        // setup ball
        ballRenderPipeline = RenderPipeline(device, shaderLib)
        let ballGeometry = CylinderGeometry()
        ballBuffers = Buffers(device, ballGeometry.indices, ballGeometry.positionVertices, ballGeometry.normalVertices)
        ballTransformBuffer = device.makeBuffer(length: MemoryLayout<simd_float4x4>.stride, options: [])!
        ballNormalBuffer = device.makeBuffer(length: MemoryLayout<simd_float3x3>.stride, options: [])!
        countOfBallIndices = ballGeometry.indices.count
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // called on resolution change
    }
    
    func drawPaddles(renderEncoder: MTLRenderCommandEncoder)
    {
        // load data to transform buffer
        var pointer = paddleTransformBuffers.contents()
        pointer.copyMemory(from: &paddle1.transformMatrix, byteCount: MemoryLayout<simd_float4x4>.stride)
        pointer.advanced(by: MemoryLayout<simd_float4x4>.stride).copyMemory(from: &paddle2.transformMatrix, byteCount: MemoryLayout<simd_float4x4>.stride)
        
        var normalMatrix1 = MatrixUtil.normalMatrix(paddle1.transformMatrix)
        var normalMatrix2 = MatrixUtil.normalMatrix(paddle2.transformMatrix)
                
        pointer = paddleNormalBuffers.contents()
        pointer.copyMemory(from: &normalMatrix1, byteCount: MemoryLayout<simd_float3x3>.stride)
        pointer.advanced(by: MemoryLayout<simd_float3x3>.stride).copyMemory(from: &normalMatrix2, byteCount: MemoryLayout<simd_float3x3>.stride)
        
        renderEncoder.setRenderPipelineState(paddleRenderPipeline.renderPipelineState)
        
        renderEncoder.setVertexBuffer(paddleBuffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(paddleBuffers.normalBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(cameraBuffers.perspectiveCameraBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(cameraBuffers.viewCameraBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBuffer(paddleTransformBuffers, offset: 0, index: 4)
        renderEncoder.setVertexBuffer(paddleNormalBuffers, offset: 0, index: 5)
        
        
        renderEncoder.drawIndexedPrimitives(
            type: MTLPrimitiveType.triangle,
            indexCount: 36,
            indexType: MTLIndexType.uint16,
            indexBuffer: paddleBuffers.indexBuffer,
            indexBufferOffset: 0,
            instanceCount: 2
        )
    }
    
    func drawBall(renderEncoder: MTLRenderCommandEncoder)
    {
        // load data to transform buffer
        ballTransformBuffer.contents().copyMemory(from: &ball.transformMatrix, byteCount: ballTransformBuffer.length)
        
        var normalMatrix = MatrixUtil.normalMatrix(ball.transformMatrix)
        ballNormalBuffer.contents().copyMemory(from: &normalMatrix, byteCount: ballNormalBuffer.length)
        
        
        renderEncoder.setRenderPipelineState(ballRenderPipeline.renderPipelineState)
        
        renderEncoder.setVertexBuffer(ballBuffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(ballBuffers.normalBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(cameraBuffers.perspectiveCameraBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(cameraBuffers.viewCameraBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBuffer(ballTransformBuffer, offset: 0, index: 4)
        
        
        renderEncoder.drawIndexedPrimitives(
            type: MTLPrimitiveType.triangle,
            indexCount: countOfBallIndices,
            indexType: MTLIndexType.uint16,
            indexBuffer: ballBuffers.indexBuffer,
            indexBufferOffset: 0,
            instanceCount: 1
        )
    }
    
    func draw(in view: MTKView) {
        
        paddle1.update()
        paddle2.update()
        
        // if there is no drawable, return
        guard let drawable = view.currentDrawable else {
            return
        }
        
        let device = view.device!
        
        // depth stencil
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .less
        depthStencilDescriptor.isDepthWriteEnabled = true
        let depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
        
        // depth texture
        let depthTextureDescriptor = MTLTextureDescriptor()
        depthTextureDescriptor.pixelFormat = .depth32Float
        depthTextureDescriptor.width = Int(view.drawableSize.width)
        depthTextureDescriptor.height = Int(view.drawableSize.height)
        depthTextureDescriptor.usage = .renderTarget
        let depthTexture = device.makeTexture(descriptor: depthTextureDescriptor)
        
        
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 0.0, 0.0, 1.0)
        renderPassDescriptor.stencilAttachment.clearStencil = 0
        renderPassDescriptor.depthAttachment.texture = depthTexture
        
        
        // create command buffer
        let commandQueue = device.makeCommandQueue()!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        // create a render command encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(.none)
        renderEncoder.setFrontFacing(.clockwise)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        // DRAW HERE

        // load data to perspective buffer and view buffer
        cameraBuffers.perspectiveCameraBuffer
            .contents()
            .copyMemory(
                from: &camera.perspectiveMatrix,
                byteCount: cameraBuffers.perspectiveCameraBuffer.length
            )
        
        cameraBuffers.viewCameraBuffer
            .contents()
            .copyMemory(
            from: &camera.viewMatrix,
            byteCount: cameraBuffers.viewCameraBuffer.length
        )

        drawPaddles(renderEncoder: renderEncoder)
        drawBall(renderEncoder: renderEncoder)
       
        
        // END DRAW HERE
        
        // end encoding
        renderEncoder.endEncoding()
        
        // present the drawable
        commandBuffer.present(drawable)
        
        commandBuffer.commit()
    }
    
    
}
