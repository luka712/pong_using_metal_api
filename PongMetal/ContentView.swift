//
//  ContentView.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {
    
    @Binding var backgroundColor: Color
    @Binding var leftPaddleColor: Color
    @Binding var rightPaddleColor: Color
    @Binding var ballColor: Color
    @Binding var splitScreen: Bool
    
    
    func makeNSView(context: Context) -> MTKView {
       
        let view = MTKView()
        view.delegate = context.coordinator
        view.device =  MTLCreateSystemDefaultDevice()
        view.drawableSize = CGSize(width: GameSetup.gameWidth, height: GameSetup.gameHeight)
        view.preferredFramesPerSecond = 60
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
        context.coordinator.splitScreen = splitScreen
        
        setColor(colorOut: &context.coordinator.backgroundColor, colorIn: backgroundColor)
        
        // setup paddle colors
        setColor(
                colorOut: &context.coordinator.paddle1.material.diffuseColor,
                colorIn: leftPaddleColor)
        
        setColor(
                colorOut: &context.coordinator.paddle2.material.diffuseColor,
                colorIn: rightPaddleColor)
        
        // setup ball color
        setColor(colorOut: &context.coordinator.ball.material.diffuseColor,  colorIn: ballColor)
        
    }
  
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    private func setColor( colorOut: inout simd_float4, colorIn: Color)
    {
        // create color
        
        guard let c = NSColor(colorIn).usingColorSpace(.deviceRGB) else {
            fatalError("Color conversion failed")
        }
        
        let r = Float(c.redComponent)
        let g = Float(c.greenComponent)
        let b = Float(c.blueComponent)
        let a = Float(c.alphaComponent)
            
            
        colorOut.x = r
        colorOut.y = g
        colorOut.z = b
        colorOut.w = a
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            backgroundColor: Binding.constant(.cyan),
            leftPaddleColor: Binding.constant(Color.gray),
            rightPaddleColor: Binding.constant(Color.gray),
            ballColor: Binding.constant(Color.white),
            splitScreen: Binding.constant(false)
        ).frame(width: GameSetup.frameWidth, height: GameSetup.frameHeight)
    }
}
