//
//  CubeGeometry.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.58.23.
//

import Foundation

struct CubeGeometry
{
    let indices: [uint16] = [
        0,  1,  2,      0,  2,  3,    // front
        4,  5,  6,      4,  6,  7,    // back
        8,  9,  10,     8,  10, 11,   // top
        12, 13, 14,     12, 14, 15,   // bottom
        16, 17, 18,     16, 18, 19,   // right
        20, 21, 22,     20, 22, 23,   // left
    ];
    
    let positionVertices: [Float] = [
        // Front face
        -0.5, -0.5,  0.5,
        0.5, -0.5,  0.5,
        0.5,  0.5,  0.5,
        -0.5,  0.5,  0.5,

         // Back face
         -0.5, -0.5, -0.5,
         -0.5,  0.5, -0.5,
         0.5,  0.5, -0.5,
         0.5, -0.5, -0.5,
         
         // Top face
         -0.5,  0.5, -0.5,
         -0.5,  0.5,  0.5,
         0.5,  0.5,  0.5,
         0.5,  0.5, -0.5,
         
         // Bottom face
         -0.5, -0.5, -0.5,
         0.5, -0.5, -0.5,
         0.5, -0.5,  0.5,
         -0.5, -0.5,  0.5,
         
         // Right face
         0.5, -0.5, -0.5,
         0.5,  0.5, -0.5,
         0.5,  0.5,  0.5,
         0.5, -0.5,  0.5,
         
         // Left face
         -0.5, -0.5, -0.5,
         -0.5, -0.5,  0.5,
         -0.5,  0.5,  0.5,
         -0.5,  0.5, -0.5
    ];
    
    var normalVertices : [Float] = [
    ]
    
    init()
    {
        self.normalVertices = GeometryUtil.calcNormals(vertices: positionVertices, indices: indices)
    }
}
