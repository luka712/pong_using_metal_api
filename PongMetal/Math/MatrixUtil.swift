//
//  MatrixUtil.swift
//  PongMetal
//
//  Created by Luka Erkapic on 21.08.23.
//

import Foundation
import simd

struct MatrixUtil
{
    
    static func perspectiveProjectionMatrix(_ fovRadians: Float, _ aspectRatio: Float, _ nearZ: Float, _ farZ: Float) -> simd_float4x4 {
        let yScale = 1.0 / tanf(fovRadians * 0.5)
        let xScale = yScale / aspectRatio
        let zScale = farZ / (nearZ - farZ)

        return simd_float4x4(
            simd_float4(xScale, 0, 0, 0),
            simd_float4(0, yScale, 0, 0),
            simd_float4(0, 0, zScale, -1),
            simd_float4(0, 0, zScale * nearZ, 0)
        );
    }
    
    static func lookAtMatrix(_ eye: simd_float3, _ target: simd_float3, _ up: simd_float3) -> simd_float4x4 {
        let zAxis = normalize(eye - target)
        let xAxis = normalize(cross(up, zAxis))
        let yAxis = cross(zAxis, xAxis)
          
        return simd_float4x4(simd_float4(xAxis.x, yAxis.x, zAxis.x, 0),
                               simd_float4(xAxis.y, yAxis.y, zAxis.y, 0),
                               simd_float4(xAxis.z, yAxis.z, zAxis.z, 0),
                               simd_float4(-dot(xAxis, eye), -dot(yAxis, eye), -dot(zAxis, eye), 1))

    }
    
    static func translation(_ x: Float, _ y: Float, _ z: Float) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1)
        );
    }
    
    static func scale(_ x: Float , _ y: Float, _ z: Float ) -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(x, 0, 0, 0),
            simd_float4(0, y, 0, 0),
            simd_float4(0, 0, z, 0),
            simd_float4(0, 0, 0, 1)
        );

    }
    
    
    static func rotationMatrix(angle: Float, axis: simd_float3) -> simd_float4x4 {
        let normalizedAxis = normalize(axis)
        let cosAngle = cos(angle)
        let sinAngle = sin(angle)
        let oneMinusCos = 1 - cosAngle
        
        let x = normalizedAxis.x
        let y = normalizedAxis.y
        let z = normalizedAxis.z
        
        var rotationMatrix = identity()
        
        rotationMatrix[0][0] = cosAngle + x * x * oneMinusCos
        rotationMatrix[0][1] = x * y * oneMinusCos - z * sinAngle
        rotationMatrix[0][2] = x * z * oneMinusCos + y * sinAngle
        
        rotationMatrix[1][0] = y * x * oneMinusCos + z * sinAngle
        rotationMatrix[1][1] = cosAngle + y * y * oneMinusCos
        rotationMatrix[1][2] = y * z * oneMinusCos - x * sinAngle
        
        rotationMatrix[2][0] = z * x * oneMinusCos - y * sinAngle
        rotationMatrix[2][1] = z * y * oneMinusCos + x * sinAngle
        rotationMatrix[2][2] = cosAngle + z * z * oneMinusCos
        
        return rotationMatrix
    }

    static func identity() -> simd_float4x4 {
        return simd_float4x4(
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(0, 0, 0, 1)
        );
    }
   
    static func normalMatrix(_ matrix: simd_float4x4) -> simd_float3x3
    {
        let upperLeft3x3 = simd_float3x3(
            simd_float3(matrix.columns.0.x, matrix.columns.1.x, matrix.columns.2.x),
            simd_float3(matrix.columns.0.y, matrix.columns.1.y, matrix.columns.2.y),
            simd_float3(matrix.columns.0.z, matrix.columns.1.z, matrix.columns.2.z)
        )
        
        // calculate the transponse inverse of upper-left 3x3
        let normalMatrix = upperLeft3x3.transpose.inverse
        
        return normalMatrix
    }


}
