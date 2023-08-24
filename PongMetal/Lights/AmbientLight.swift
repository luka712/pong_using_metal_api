//
//  AmbientLight.swift
//  PongMetal
//
//  Created by Luka Erkapic on 24.08.23.
//

import Foundation
import simd // for simd_float4
import Metal

struct AmbientLight
{
    public var color: simd_float4
    
    init( color: simd_float4 = simd_float4(0.4,0.4,0.4,1.0))
    {
        self.color = color
    }
}
