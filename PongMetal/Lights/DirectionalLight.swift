//
//  DirectionalLight.swift
//  PongMetal
//
//  Created by Luka Erkapic on 24.08.23.
//

import Foundation
import simd

struct DirectionalLight
{
    public var direction: simd_float3
    public var color: simd_float4
    
    init( direction: simd_float3 = simd_float3(0,-1,0),
          color: simd_float4 = simd_float4(0.8,0.8,0.8,1.0))
    {
        self.color = color
        self.direction = direction
    }
}
