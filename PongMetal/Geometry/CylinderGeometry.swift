//
//  CylinderGeometry.swift
//  PongMetal
//
//  Created by Luka Erkapic on 23.08.23.
//

import Foundation
struct CylinderGeometry
{
    var indices: [uint16];
    var positionVertices: [Float];
    var normalVertices: [Float]
    
    init()
    {
        let radius: Float = 0.5
        // latitudes
        let segments = 32
        
        positionVertices = [
            0,-0.25, 0, // bottom center
            0, 0.25, 0  // top center
        ]
        indices = []
        
        let step = (.pi * 2.0) /  Float(segments)
        
        // add bottom vertices
        for a in stride(from: 0.0, to: .pi * 2 + step, by: step){
            
            let c = cosf(a) * radius
            let s = sinf(a) * radius
            
            positionVertices.append(c)
            positionVertices.append(-0.25)
            positionVertices.append(s)
        }
        
        // add top vertices
        for a in stride(from: 0.0, to: .pi * 2 + step, by: step){
            
            let c = cosf(a) * radius
            let s = sinf(a) * radius
            
            positionVertices.append(c)
            positionVertices.append(0.25)
            positionVertices.append(s)
        }
        
        // add bottom indices
        // step first 2 center vertices
        var i = 2
        for _ in stride(from: 0.0, to: .pi * 2, by: step){
         
            indices.append(0)
            indices.append(uint16(i))
            indices.append(uint16(i+1))
            
            i += 1
        }
        
        
        // here advance for 1 since it's finsihed
        i += 1
        
        // add top indices
        for _ in stride(from: 0.0, to: .pi * 2, by: step){
         
            indices.append(1)
            indices.append(uint16(i+1))
            indices.append(uint16(i))
            
            i += 1
        }
        
        // connect top and bottom with indices
        
        for a in stride(from: 0.0, to: .pi * 2, by: step){
            
            let i = positionVertices.count / 3

            
            let c1 = cosf(a) * radius
            let s1 = sinf(a) * radius
            
            let c2 = cosf(a + step) * radius
            let s2 = sinf(a + step) * radius
            
            
            positionVertices.append(c1)
            positionVertices.append(0.25)
            positionVertices.append(s1)
            
            positionVertices.append(c2)
            positionVertices.append(0.25)
            positionVertices.append(s2)
            
            positionVertices.append(c2)
            positionVertices.append(-0.25)
            positionVertices.append(s2)
            
            positionVertices.append(c1)
            positionVertices.append(-0.25)
            positionVertices.append(s1)
            
            indices.append(uint16(i))
            indices.append(uint16(i+1))
            indices.append(uint16(i+2))
            
            indices.append(uint16(i+2))
            indices.append(uint16(i+3))
            indices.append(uint16(i))
        }
        
        
        // finally get normals
        normalVertices = GeometryUtil.calcNormals(vertices: positionVertices, indices: indices)
    }
}
