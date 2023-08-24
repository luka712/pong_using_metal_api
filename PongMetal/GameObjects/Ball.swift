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
        let translationMatrix = MatrixUtil.translation(position.x, position.y, position.z)
        transformMatrix = translationMatrix
    }
}
