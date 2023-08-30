//
//  QuadGeometry.swift
//  PongMetal
//
//  Created by Luka Erkapic on 29.08.23.
//

import Foundation

struct QuadGeometry
{
    public let indices: [uint16] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    public let vertices: [Float] = [
        -1, -1, 0,
        1, -1, 0,
        1, 1, 0,
        -1, 1, 0,
    ]
    
    public let uvCoords: [Float] = [
        0, 1,
        1, 1,
        1, 0,
        0, 0
    ]
    
}
