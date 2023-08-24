//
//  CameraBuffers.swift
//  PongMetal
//
//  Created by Luka Erkapic on 21.08.23.
//

import Foundation
import simd
import Metal

class CameraBuffers
{
    private let _perspectiveCameraBuffer: MTLBuffer
    private let _viewCameraBuffer: MTLBuffer
    
    var perspectiveCameraBuffer: MTLBuffer {
        get { return _perspectiveCameraBuffer }
    }
    
    var viewCameraBuffer: MTLBuffer {
        get { return _viewCameraBuffer }
    }
    
    
    init(_ device: MTLDevice)
    {
        _perspectiveCameraBuffer = device.makeBuffer( length: MemoryLayout<Float>.stride * 16, options: [])!
        _viewCameraBuffer = device.makeBuffer( length: MemoryLayout<Float>.stride * 16, options: [])!
    }
    
    func writeToBuffers(camera: inout Camera)
    {
        // load data to perspective buffer and view buffer
        _perspectiveCameraBuffer
            .contents()
            .copyMemory(
                from: &camera.perspectiveMatrix,
                byteCount: _perspectiveCameraBuffer.length
            )
        
        _viewCameraBuffer
            .contents()
            .copyMemory(
            from: &camera.viewMatrix,
            byteCount: _viewCameraBuffer.length
        )
    }
}
