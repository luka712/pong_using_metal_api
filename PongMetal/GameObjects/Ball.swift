//
//  Ball.swift
//  PongMetal
//
//  Created by Luka Erkapic on 22.08.23.
//

import Foundation
import simd

class Ball
{
    private var position: simd_float3
    var transformMatrix = MatrixUtil.identity()
    var material = BasicMaterial()

    private var velocity : simd_float2
    
    var _collisionRect: CollisionRect
    var collisionRect: CollisionRect { return _collisionRect }
    
    
    /**
     * The normal matrix is used to transform normals from object space to eye space.
     */
    var normalMatrix: simd_float3x3
    {
        return MatrixUtil.normalMatrix(transformMatrix)
    }
    
    init(position: simd_float3)
    {
        self.position = position
        velocity = simd_float2()
        _collisionRect = CollisionRect(0, 0,  GameSetup.ballRadius, GameSetup.ballRadius )
        reset()
    
    }
    
    private func reset()
    {
        position.x = 0
        position.z = 0
        
        var flipCoin = Int.random(in: 0...1)
        var randomX = Float(0.0)
        if flipCoin == 0{
            randomX = -1
        } else {
            randomX = 1
        }
        
        
        flipCoin = Int.random(in: 0...1)
        var randomZ = Float(0.0)
        if flipCoin == 0 {
            randomZ = -1
        } else {
            randomZ = 1
        }
        velocity = simd_float2(randomX * GameSetup.ballStartSpeed, randomZ * GameSetup.ballStartSpeed)
    }
    
    private func updateCollisionRect()
    {
        let halfWidth = GameSetup.ballRadius / 2
        let halfHeight = GameSetup.ballRadius / 2
        _collisionRect.x = position.x - halfWidth
        _collisionRect.y = position.z - halfHeight
    }
    
  
    func update()
    {
        // if bounds on z-axis are hit, reverse velocity
        
        if position.z > GameSetup.gameBoundZ || position.z < -GameSetup.gameBoundZ {
            velocity.y *= -1
        }
        
        // update position
        
        position.x  += velocity.x
        position.z  += velocity.y
        
        // if out of bounds on x-axis reset
        if position.x > GameSetup.rightPaddlePositionX || position.x < GameSetup.leftPaddlePositionX {
            reset()
        }
        
        let translationMatrix = MatrixUtil.translation(position.x , position.y, position.z )
        transformMatrix = translationMatrix

        updateCollisionRect()
    }
    
    func intersect(paddle: Paddle)
    {
        if _collisionRect.intersects(paddle.collisionRect)
        {
            velocity.x *= -1
            velocity.x *= 1.1
            velocity.y *= 1.1
            
            // left side collision
            if paddle.isLeft {
                // reset to right of paddle
                position.x = paddle.position.x + GameSetup.paddleWidth + 0.001
            
            } else  {
                // reset to left of paddle
                position.x = paddle.position.x - GameSetup.paddleWidth - 0.001
            }
         
        }
    }
    
    
}
