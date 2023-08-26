//
//  Paddle.swift
//  PongMetal
//
//  Created by Luka Erkapic on 22.08.23.
//

import Foundation
import simd

class Paddle
{
    let inputManager: InputManager
    
    // left or right paddle
    let isRight: Bool
    var isLeft: Bool { return !isRight }


    var material = BasicMaterial()
    
    var position: simd_float3
    var transformMatrix = MatrixUtil.identity()
    
    /**
     * The normal matrix is used to transform normals from object space to eye space.
     */
    var normalMatrix: simd_float3x3
    {
        return MatrixUtil.normalMatrix(transformMatrix)
    }
    
    // collision
    private var _collisionRect: CollisionRect
    var collisionRect: CollisionRect { return _collisionRect }
    
    init(_ isRight: Bool, _ inputManager: InputManager)
    {
        self.isRight = isRight
        self.inputManager = inputManager
        
        // by default setup left paddle
        self.position = simd_float3(GameSetup.leftPaddlePositionX, 0,0 )
        
        // setup right paddle
        if isRight {
            self.position.x = Float(GameSetup.rightPaddlePositionX)
        }
        
        _collisionRect = CollisionRect(0,0, GameSetup.paddleWidth, GameSetup.paddleHeight)
    }
    
    private func handleKeyboardInput()
    {
        let paddleSpeed = GameSetup.paddleSpeed

        // left
        if isLeft {
            if inputManager.isKeyPressed(.keyW) {
                position.z += paddleSpeed
            }
            else if inputManager.isKeyPressed(.keyS) {
                position.z -= paddleSpeed
            }
        }
        // right
        else {
            if inputManager.isKeyPressed(.upArrow) {
                position.z += paddleSpeed
            }
            else if inputManager.isKeyPressed(.downArrow) {
                position.z -= paddleSpeed
            }
        }
    }
    
    private func updateCollisionRect()
    {
          let halfWidth = GameSetup.paddleWidth / 2
          let halfHeight =  GameSetup.paddleHeight / 2
          _collisionRect.x = position.x - halfWidth
          _collisionRect.y = position.z - halfHeight
    }
    
    func update()
    {
        handleKeyboardInput()
        
        let scaleMatrix = MatrixUtil.scale(GameSetup.paddleWidth, 1, GameSetup.paddleHeight)
        let translationMatrix = MatrixUtil.translation(position.x, position.y, position.z)
        transformMatrix = translationMatrix * scaleMatrix

        updateCollisionRect()
    }
}
