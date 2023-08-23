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
        let segments = 16
        
        positionVertices = [
            0,-0.25, 0, // bottom center
            0, 0.25, 0  // top center
        ]
        indices = []
        
        let step = (.pi * 2.0) /  Float(segments)
        
        // add bottom vertices
        for s in stride(from: 0.0, to: .pi * 2 + step, by: step){
            
            let c = cosf(s) * radius
            let s = sinf(s) * radius
            
            positionVertices.append(c)
            positionVertices.append(-0.25)
            positionVertices.append(s)
        }
        
        // add top vertices
        for s in stride(from: 0.0, to: .pi * 2 + step, by: step){
            
            let c = cosf(s) * radius
            let s = sinf(s) * radius
            
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
        var j = i // j is needed when connectim top and bottom
        
        // add top indices
        for _ in stride(from: 0.0, to: .pi * 2, by: step){
         
            indices.append(1)
            indices.append(uint16(i))
            indices.append(uint16(i+1))
            
            i += 1
        }
        
        // connect top and bottom with indices
        
        i = 2
        for _ in stride(from: 0.0, to: .pi * 2, by: step){

            indices.append(uint16(i))
            indices.append(uint16(i + 1))
            indices.append(uint16(j))
            
            indices.append(uint16(j))
            indices.append(uint16(j + 1))
            indices.append(uint16(i + 1))
            
            i += 1
            j += 1
        }
        
        
        // finally get normals
        normalVertices = GeometryUtil.calcNormals(vertices: positionVertices, indices: indices)
    }
}
