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
    var transformMatrix = MatrixUtil.identity()
    private var position: simd_float3
    
    
    
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
