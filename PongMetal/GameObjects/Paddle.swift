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
    var transformMatrix = MatrixUtil.identity()
    var material = BasicMaterial()
    
    private var position: simd_float3
    
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
    }
    
    func update()
    {
        let scaleMatrix = MatrixUtil.scale(5, 1, 1)
        let translationMatrix = MatrixUtil.translation(position.x, position.y, position.z)
        transformMatrix = translationMatrix * scaleMatrix
    }
}
