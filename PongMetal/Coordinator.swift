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
    
    var backgroundColor: simd_float4 = simd_float4(0.0,0.0,0.0,1.0)
    
    var renderEncoder: MTLRenderCommandEncoder!
    
    let device: MTLDevice
    let shaderLib: ShaderLib
    
    let useFxaa = true
    
    let inputManager: InputManager
    
    // if true, use split screen
    var splitScreen = true
    
    // paddles
    let paddle1: Paddle
    let paddle2: Paddle
    let paddleRenderPipeline: RenderPipeline
    let paddleRenderPipeline2: RenderPipeline // only to be used if split screen
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
    var camera: Camera // for single screen
    var paddle1Camera: Camera // for split screen
    var paddle2Camera: Camera // for split screen
    let cameraBuffers: CameraBuffers
    let camera2Buffers: CameraBuffers
    
    // FXAA
    let fxaaRenderPipeline: FxaaRenderPipeline
    
    
    init(width: CGFloat = 1280.0, height:CGFloat = 720.0 )
    {
        self.width = width
        self.height = height
        
        inputManager = InputManager()
        
        self.paddle1 = Paddle(false, inputManager)
        self.paddle2 = Paddle(true, inputManager)
    
        self.camera = Camera(width,height)
        self.paddle1Camera = Camera(width, height, options: .splitScreenTop)
        self.paddle2Camera = Camera(width, height, options: .splitScreenBottom)
        
        device = MTLCreateSystemDefaultDevice()!
        shaderLib = ShaderLib(device: device)
        
        cameraBuffers = CameraBuffers(device)
        camera2Buffers = CameraBuffers(device)
        
        // setup paddles
        paddleRenderPipeline = RenderPipeline(device, shaderLib)
        paddleRenderPipeline2 = RenderPipeline(device, shaderLib)
        let cubeGeometry = CubeGeometry();
        paddleBuffers = GeometryBuffers(device, cubeGeometry.indices, cubeGeometry.positionVertices, cubeGeometry.normalVertices, nil )
        paddleInstanceBuffers = InstanceBuffers(device, instances: 2)
        
        // setup ball
        ballRenderPipeline = RenderPipeline(device, shaderLib)
        let ballGeometry = CylinderGeometry()
        ballGeometryBuffers = GeometryBuffers(device, ballGeometry.indices, ballGeometry.positionVertices, ballGeometry.normalVertices)
        ballInstanceBuffers = InstanceBuffers(device,instances: 1)
        countOfBallIndices = ballGeometry.indices.count
        
        // lights
        lightBuffer = LightBuffers(device)
        
        // FXAA
        fxaaRenderPipeline = FxaaRenderPipeline(device)
        
        super.init()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // called on resolution change
    }
    
    func drawPaddles(pipeline: RenderPipeline, cameraBuffer: CameraBuffers)
    {
        // load data to transform buffer
        var normal1 = paddle1.normalMatrix
        var normal2 = paddle2.normalMatrix
        
        var diffColor1 = paddle1.material.diffuseColor
        var diffColor2 = paddle2.material.diffuseColor
        
        paddleInstanceBuffers.writeToBuffers(instance: 0, transformMatrix: &paddle1.transformMatrix, normalMatrix: &normal1, diffuseColor: &diffColor1)
        paddleInstanceBuffers.writeToBuffers(instance: 1, transformMatrix: &paddle2.transformMatrix, normalMatrix: &normal2, diffuseColor: &diffColor2)
        
        // draw paddles
        
        pipeline.draw(renderEncoder: renderEncoder,
                      indexCount: 36,
                      instanceCount: 2,
                      geometryBuffers: paddleBuffers,
                      cameraBuffers: cameraBuffer, // only diff is camera buffers
                      instanceBuffers: paddleInstanceBuffers,
                      lightBuffers: lightBuffer
        )
            
          
    }
    
    func drawBall()
    {
        // load data to transform buffer
        var normal = ball.normalMatrix
        var diffColor = ball.material.diffuseColor
        ballInstanceBuffers.writeToBuffers(instance: 0, transformMatrix: &ball.transformMatrix, normalMatrix: &normal, diffuseColor: &diffColor)

        ballRenderPipeline.draw(renderEncoder: renderEncoder,
                                indexCount: countOfBallIndices,
                                instanceCount: 1,
                                geometryBuffers: ballGeometryBuffers,
                                cameraBuffers: cameraBuffers,
                                instanceBuffers: ballInstanceBuffers,
                                lightBuffers: lightBuffer)
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
    
    func setupRenderCommandEncoder(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) -> MTLRenderCommandEncoder
    {
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

        // if fxaa is used, texture is set to texture which will be used by post process fxaa pass, else use the view texture
        if useFxaa {
            renderPassDescriptor.colorAttachments[0].texture = fxaaRenderPipeline.destinationTexture
        }
        else{
            renderPassDescriptor.colorAttachments[0].texture =  view.currentDrawable?.texture
        }
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(
            Double(backgroundColor.x),
            Double(backgroundColor.y),
            Double(backgroundColor.z),
            Double(backgroundColor.w))
        renderPassDescriptor.stencilAttachment.clearStencil = 0
        renderPassDescriptor.depthAttachment.texture = depthTexture
        
        // create a render command encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setCullMode(.back)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setDepthStencilState(depthStencilState)
    
        return renderEncoder
    }
    
    func update() {
        paddle1.update()
        paddle2.update()
        ball.update()
        
        clampPaddle(paddle: paddle1)
        clampPaddle(paddle: paddle2)
        
        ball.intersect(paddle: paddle1)
        ball.intersect(paddle: paddle2)
    }
        
    func draw(in view: MTKView) {
    
        update()
        
        
        // create command buffer
        let commandQueue = device.makeCommandQueue()!
        let commandBuffer = commandQueue.makeCommandBuffer()!
        renderEncoder = setupRenderCommandEncoder(view, commandBuffer)
        
        // DRAW HERE
        
        // load lights data
        lightBuffer.writeIntoBuffers(ambientLight: &ambientLight, directionalLight: &directionalLight)

        if splitScreen {
            
            // player 1
            renderEncoder.setViewport(MTLViewport(
                originX: 0, originY: 0,
                width: GameSetup.gameWidth, height: GameSetup.gameHeight / 2,
                znear: 0.0, zfar: 1.0
            ))
            
            renderEncoder.setScissorRect(MTLScissorRect(
                x: 0, y: 0,
                width: Int(GameSetup.gameWidth), height: Int(GameSetup.gameHeight / 2)
            ))
            
            // load data to perspective buffer and view buffer
            cameraBuffers.writeToBuffers(camera: &paddle1Camera)
            
            drawPaddles(pipeline: paddleRenderPipeline, cameraBuffer: cameraBuffers)
            drawBall()
        
            // player 2
            renderEncoder.setViewport(MTLViewport(
                originX: 0, originY: GameSetup.gameHeight / 2,
                width: GameSetup.gameWidth, height: GameSetup.gameHeight / 2,
                znear: 0.0, zfar: 1.0
            ))
            
            renderEncoder.setScissorRect(MTLScissorRect(
                x: 0, y: Int(GameSetup.gameHeight / 2),
                width: Int(GameSetup.gameWidth), height: Int(GameSetup.gameHeight / 2)
            ))
            
            // load data to perspective buffer and view buffer
            camera2Buffers.writeToBuffers(camera: &paddle2Camera)

            drawPaddles(pipeline: paddleRenderPipeline2, cameraBuffer: camera2Buffers)
            drawBall()
            

        }
        else {
            cameraBuffers.writeToBuffers(camera: &camera)
            drawPaddles(pipeline: paddleRenderPipeline, cameraBuffer: cameraBuffers)
            drawBall()
        }
        // END DRAW HERE
        renderEncoder.endEncoding()

        // POST PROCESS
        // FXAA
        if useFxaa {
            // if fxaa is used we create another render command encoder
            let renderPassDesc =  MTLRenderPassDescriptor()
            renderPassDesc.colorAttachments[0].texture = view.currentDrawable?.texture
            renderPassDesc.colorAttachments[0].loadAction = .clear
            renderPassDesc.colorAttachments[0].clearColor = MTLClearColorMake(
                Double(backgroundColor.x),
                Double(backgroundColor.y),
                Double(backgroundColor.z),
                Double(backgroundColor.w))
            renderPassDesc.colorAttachments[0].storeAction = .store
            
            let fxaaRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDesc)!
            fxaaRenderPipeline.draw(renderEncoder: fxaaRenderEncoder)
            
            fxaaRenderEncoder.endEncoding()
            
        }
        
        // present the drawable

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    
}
