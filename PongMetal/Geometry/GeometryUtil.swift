//
//  GeometryUtil.swift
//  PongMetal
//
//  Created by Luka Erkapic on 23.08.23.
//

import Foundation
import simd

struct GeometryUtil
{
    /**
     * Calculates normals for each vertex in the mesh.
     * @param vertices The vertices of the mesh
     * @param indices The indices of the mesh
     * @return The normals of the mesh
     */
    static func calcNormals(vertices: [Float], indices: [uint16]) -> [Float]
    {
        var normals = [Float](repeating: 0, count: vertices.count)

        for i in stride(from: 0, to: indices.count, by: 3)
        {
            let p0 = Int(indices[i]) * 3 // each vertex has x,y,z so 3 indices
            let p1 = Int(indices[i+1]) * 3
            let p2 = Int(indices[i+2]) * 3
            
            let a = simd_float3(vertices[p0], vertices[p0+1], vertices[p0+2])
            let b = simd_float3(vertices[p1], vertices[p1+1], vertices[p1+2])
            let c = simd_float3(vertices[p2], vertices[p2+1], vertices[p2+2])

            let u = b - a
            let v = c - a
            
            let n = normalize(simd_cross(u, v))

            normals[p0] = n.x
            normals[p0+1] = n.y
            normals[p0+2] = n.z
            
            normals[p1] = n.x
            normals[p1+1] = n.y
            normals[p1+2] = n.z
            
            normals[p2] = n.x
            normals[p2+1] = n.y
            normals[p2+2] = n.z
        }
        
        return normals
    }
}
