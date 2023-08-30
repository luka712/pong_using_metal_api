//
//  Camera.swift
//  PongMetal
//
//  Created by Luka Erkapic on 22.08.23.
//

import Foundation
import simd

enum CameraOptions
{
    case singleScreen;
    case splitScreenTop;
    case splitScreenBottom;
}

struct Camera
{
    var viewMatrix: simd_float4x4
    var perspectiveMatrix: simd_float4x4
    
    init(_ width: CGFloat, _ height: CGFloat, options: CameraOptions = .singleScreen)
    {
        
        if options == CameraOptions.singleScreen {
            perspectiveMatrix = MatrixUtil.perspectiveProjectionMatrix(Float.pi * 0.33, Float(width/height), 0.1, 1000.0)
            viewMatrix = MatrixUtil.lookAtMatrix(simd_float3(0.000001,-12,0), simd_float3(0,0,0), simd_float3(0,1,0))
            viewMatrix *= MatrixUtil.rotationMatrix(angle:  .pi / 2, axis: simd_float3(0,-1,0))
        }
        // or left player ( player 1)
        else if options == CameraOptions.splitScreenTop {
            perspectiveMatrix = MatrixUtil.perspectiveProjectionMatrix(Float.pi * 0.6, Float(width/height), 0.1, 1000.0)
            viewMatrix = MatrixUtil.lookAtMatrix(simd_float3(12,-4,0), simd_float3(0,0,0), simd_float3(0,-1,0))
            viewMatrix *= MatrixUtil.rotationMatrix(angle:  .pi, axis: simd_float3(0,1,0))
        }
        // or right player ( player 2)
        else {
            perspectiveMatrix = MatrixUtil.perspectiveProjectionMatrix(Float.pi * 0.6, Float(width/height), 0.1, 1000.0)
            viewMatrix = MatrixUtil.lookAtMatrix(simd_float3(-12,-4,0), simd_float3(0,0,0), simd_float3(0,-1,0))
            viewMatrix *= MatrixUtil.rotationMatrix(angle:  .pi, axis: simd_float3(0,1,0))
        }
    }
}
