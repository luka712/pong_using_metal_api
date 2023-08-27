//
//  GameSetup.swift
//  PongMetal
//
//  Created by Luka Erkapic on 26.08.23.
//

import Foundation


struct GameSetup
{
    static let leftPaddlePositionX: Float  = -10
    static let rightPaddlePositionX: Float = 10
    
    static let paddleWidth: Float = 1
    static let paddleHeight: Float = 5
    static let paddleSpeed: Float = 0.15
    
    static let gameBoundZ: Float = 7
    
    static let ballStartSpeed: Float = 0.15
    static let ballRadius: Float = 1
    
    static let gameWidth = 1280.0
    static let gameHeight = 720.0
}
