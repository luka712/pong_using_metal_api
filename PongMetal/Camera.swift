//
//  Camera.swift
//  PongMetal
//
//  Created by Luka Erkapic on 22.08.23.
//

import Foundation
import simd

struct Camera
{
    var viewMatrix: simd_float4x4
    var perspectiveMatrix: simd_float4x4
    
    init(_ width: CGFloat, _ height: CGFloat)
    {
        perspectiveMatrix = MatrixUtil.perspectiveProjectionMatrix(Float.pi * 0.33, Float(width/height), 0.1, 1000.0)
        
       //  viewMatrix = MatrixUtil.lookAtMatrix(simd_float3(0.000001,12,0), simd_float3(0,0,0), simd_float3(0,1,0))
        viewMatrix = MatrixUtil.lookAtMatrix(simd_float3(4,4,4), simd_float3(0,0,0), simd_float3(0,1,0))
    }
}
