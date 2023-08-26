//
//  Coordinator.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import Foundation
import MetalKit
import GameController

class Coordinator : NSObject, MTKViewDelegate {

    let width: CGFloat
    let height: CGFloat
    
    let device: MTLDevice
    let shaderLib: ShaderLib
    
    let inputManager: InputManager
    
    
    // paddles
    let paddle1: Paddle
    let paddle2: Paddle
    let paddleRenderPipeline: RenderPipeline
    let paddleInstanceBuffers: InstanceBuffers
    let paddleBuffers: GeometryBuffers

    // ball
    let ball = Ball(position: simd_float3(0.0,0.0,0.0))
    let ballRenderPipeline: RenderPipeline
    let ballInstanceBuffers: InstanceBuffers
    let ballGeometryBuffers: GeometryBuffers
    let countOfBallIndices: Int
    
    // light
    var ambientLight = AmbientLight()
    var directionalLight = DirectionalLight(direction: simd_float3(0,1,0))
    let lightBuffer: LightBuffers
    

    // camera
    var camera: Camera
    let cameraBuffers: CameraBuffers
    
    
    init(width: CGFloat = 1280.0, height:CGFloat = 720.0 )
    {
        self.width = width
        self.height = height
        
        inputManager = InputManager()
        
        self.paddle1 = Paddle(false, inputManager)
        self.paddle2 = Paddle(true, inputManager)
    
        self.camera = Camera(width,height)
        
        device = MTLCreateSystemDefaultDevice()!
        shaderLib = ShaderLib(device: device)
        
        cameraBuffers = CameraBuffers(device)
        
        // setup paddles
        paddleRenderPipeline = RenderPipeline(device, shaderLib)
        let cubeGeometry = CubeGeometry();
        paddleBuffers = GeometryBuffers(device, cubeGeometry.indices, cubeGeometry.positionVertices, cubeGeometry.normalVertices)
        paddleInstanceBuffers = InstanceBuffers(device, instances: 2)
        
        
        // setup ball
        ballRenderPipeline = RenderPipeline(device, shaderLib)
        let ballGeometry = CylinderGeometry()
        ballGeometryBuffers = GeometryBuffers(device, ballGeometry.indices, ballGeometry.positionVertices, ballGeometry.normalVertices)
        ballInstanceBuffers = InstanceBuffers(device,instances: 1)
        countOfBallIndices = ballGeometry.indices.count
        
        // lights
        lightBuffer = LightBuffers(device)
        
        super.init()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // called on resolution change
    }
    
    func drawPaddles(renderEncoder: MTLRenderCommandEncoder)
    {
        // load data to transform buffer
        var normal1 = paddle1.normalMatrix
        var normal2 = paddle2.normalMatrix
        
        var diffColor1 = paddle1.material.diffuseColor
        var diffColor2 = paddle2.material.diffuseColor
        
        paddleInstanceBuffers.writeToBuffers(instance: 0, transformMatrix: &paddle1.transformMatrix, normalMatrix: &normal1, diffuseColor: &diffColor1)
        paddleInstanceBuffers.writeToBuffers(instance: 1, transformMatrix: &paddle2.transformMatrix, normalMatrix: &normal2, diffuseColor: &diffColor2)

        
        renderEncoder.setRenderPipelineState(paddleRenderPipeline.renderPipelineState)
        
        renderEncoder.setVertexBuffer(paddleBuffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(paddleBuffers.normalBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(cameraBuffers.perspectiveCameraBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(cameraBuffers.viewCameraBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBuffer(paddleInstanceBuffers.transformBuffer, offset: 0, index: 4)
        renderEncoder.setVertexBuffer(paddleInstanceBuffers.normalBuffer, offset: 0, index: 5)
        renderEncoder.setVertexBuffer(paddleInstanceBuffers.diffuseColorBuffer, offset: 0, index: 6)
        renderEncoder.setVertexBuffer(lightBuffer.ambientLightBuffer, offset: 0, index: 7)
        renderEncoder.setVertexBuffer(lightBuffer.directionalLightDirectionBuffer, offset: 0, index: 8)
        renderEncoder.setVertexBuffer(lightBuffer.directionalLightColorBuffer, offset: 0, index: 9)
        
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
        var normal = ball.normalMatrix
        var diffColor = ball.material.diffuseColor
        ballInstanceBuffers.writeToBuffers(instance: 0, transformMatrix: &ball.transformMatrix, normalMatrix: &normal, diffuseColor: &diffColor)

        renderEncoder.setRenderPipelineState(ballRenderPipeline.renderPipelineState)
        
        renderEncoder.setVertexBuffer(ballGeometryBuffers.vertexPositionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(ballGeometryBuffers.normalBuffer, offset: 0, index: 1)
        renderEncoder.setVertexBuffer(cameraBuffers.perspectiveCameraBuffer, offset: 0, index: 2)
        renderEncoder.setVertexBuffer(cameraBuffers.viewCameraBuffer, offset: 0, index: 3)
        renderEncoder.setVertexBuffer(ballInstanceBuffers.transformBuffer, offset: 0, index: 4)
        renderEncoder.setVertexBuffer(ballInstanceBuffers.normalBuffer, offset: 0, index: 5)
        renderEncoder.setVertexBuffer(ballInstanceBuffers.diffuseColorBuffer, offset: 0, index: 6)
        renderEncoder.setVertexBuffer(lightBuffer.ambientLightBuffer, offset: 0, index: 7)
        renderEncoder.setVertexBuffer(lightBuffer.directionalLightDirectionBuffer, offset: 0, index: 8)
        renderEncoder.setVertexBuffer(lightBuffer.directionalLightColorBuffer, offset: 0, index: 9)
        
        renderEncoder.drawIndexedPrimitives(
            type: MTLPrimitiveType.triangle,
            indexCount: countOfBallIndices,
            indexType: MTLIndexType.uint16,
            indexBuffer: ballGeometryBuffers.indexBuffer,
            indexBufferOffset: 0,
            instanceCount: 1
        )
    }
    
    func clampPaddle(paddle: Paddle){
        
        let bound = Float(5)
        
        if paddle.position.z > bound {
            paddle.position.z = bound
        }
        else if paddle.position.z < -bound {
            paddle.position.z = -bound
        }
        
    }
        
    func draw(in view: MTKView) {
        
      
        
        paddle1.update()
        paddle2.update()
        ball.update()
        
        clampPaddle(paddle: paddle1)
        clampPaddle(paddle: paddle2)
        
        ball.intersect(paddle: paddle1)
        ball.intersect(paddle: paddle2)

        
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
        renderEncoder.setCullMode(.back)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setDepthStencilState(depthStencilState)
        
        // DRAW HERE

        // load data to perspective buffer and view buffer
        cameraBuffers.writeToBuffers(camera: &camera)
        
        // load lights data
        lightBuffer.writeIntoBuffers(ambientLight: &ambientLight, directionalLight: &directionalLight) 
        
        
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
