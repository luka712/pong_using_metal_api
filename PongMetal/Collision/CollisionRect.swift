//
//  CollisionRect.swift
//  PongMetal
//
//  Created by Luka Erkapic on 26.08.23.
//

import Foundation

struct CollisionRect
{
    public var x: Float
    public var y: Float
    public var width: Float
    public var height: Float
    
    
    init(_ x: Float, _ y: Float, _ width: Float, _ height: Float)
    {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    func intersects(_ other: CollisionRect) -> Bool
    {
        return x < other.x + other.width &&
            x + width > other.x &&
            y < other.y + other.height &&
            y + height > other.y
    }
    
    

}
