//
//  GeometryBuffers.swift
//  PongMetal
//
//  Created by Luka Erkapic on 24.08.23.
//

import Foundation
import Metal

/**
 * Buffers for game objects geometry
 */
class GeometryBuffers
{
    private let _indexBuffer: MTLBuffer
    private let _vertexPositionBuffer: MTLBuffer
    private var _normalBuffer: MTLBuffer? = nil
    private var _coordsBuffer: MTLBuffer? = nil
    
    var indexBuffer: MTLBuffer { return _indexBuffer}
    
    var vertexPositionBuffer: MTLBuffer { return _vertexPositionBuffer }
    
    var normalBuffer: MTLBuffer? { return _normalBuffer }
    
    var texCoordsBuffer: MTLBuffer? { return _coordsBuffer }
    
    
    init(_ device: MTLDevice, _ indicesData: [uint16], _ positionsData: [Float], _ normalsData: [Float]? = nil, _ uvData: [Float]? = nil)
    {
        // create index buffer
        _indexBuffer = device.makeBuffer(bytes: indicesData, length: MemoryLayout<uint16>.stride * indicesData.count, options: [])!
        
        // create vertex buffer
        _vertexPositionBuffer = device.makeBuffer(bytes: positionsData, length: MemoryLayout<Float>.stride * positionsData.count, options: [])!
        
        if normalsData != nil {
            // create normal buffer
            _normalBuffer = device.makeBuffer(bytes: normalsData!, length: MemoryLayout<Float>.stride * normalsData!.count, options: [])!
        }
        
        if uvData != nil {
            // create uv buffer
            _coordsBuffer = device.makeBuffer(bytes: uvData!, length: MemoryLayout<Float>.stride * uvData!.count, options: [])!
        }
    
    }
}
