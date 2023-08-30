//
//  ShaderLib.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import Foundation
import Metal

class ShaderLib
{
    private let device: MTLDevice
    private var _shaderLibrary: MTLLibrary? = nil
    private var _vertexFunction: MTLFunction? = nil
    private var _fragmentFunction: MTLFunction? = nil
    
    var shaderLibrary: MTLLibrary? {
        get { return _shaderLibrary }
    }
    
    var vertexFunction: MTLFunction? {
        get { return _vertexFunction }
    }
    
    var fragmentFunction: MTLFunction? {
        get { return _fragmentFunction }
    }
    
    
    init( device: MTLDevice, vertexFnName: String = "vs_main", fragmentFnName: String = "fs_main")
    {
        self.device = device
        load( vertexFnName, fragmentFnName )
    }
    
    private func load(_ vertexFnName: String , _ fragmentFnName: String)
    {

        // try to find library file
        _shaderLibrary = device.makeDefaultLibrary()
                                    
        // find vertex functions
        guard let vFn = _shaderLibrary?.makeFunction(name: vertexFnName) else {
            print("Vertex function not found")
            return
        }
        guard let fFn = _shaderLibrary?.makeFunction(name: fragmentFnName) else {
            print("Fragment function not found")
            return
        }
            
        _vertexFunction = vFn
        _fragmentFunction = fFn
    }
     
    
    private func loadCompiled()
    {
        // if library file is not found, return
        guard let libraryFile = Bundle.main.path(forResource: "shader", ofType: "metallib") else {
            print("Library file not found!")
            return
        }
        
        do {
            // try to find library file
            let url = URL(filePath: libraryFile)
            _shaderLibrary = try device.makeLibrary(URL: url)
            
            // find vertex functions
            guard let vFn = _shaderLibrary?.makeFunction(name: "vs_main") else {
                print("Vertex function not found")
                return
            }
            guard let fFn = _shaderLibrary?.makeFunction(name: "fs_main") else {
                print("Fragment function not found")
                return
            }
            
            _vertexFunction = vFn
            _fragmentFunction = fFn
        }
        // if not found catch error
        catch let error {
            print("Library error :\(error.localizedDescription)")
        }
    }
}
