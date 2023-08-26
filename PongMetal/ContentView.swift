//
//  ContentView.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import SwiftUI
import MetalKit

struct ContentView: NSViewRepresentable {
    
     func makeNSView(context: Context) -> MTKView {
       
        let view = MTKView()
        view.delegate = context.coordinator
        view.device =  MTLCreateSystemDefaultDevice()
        view.drawableSize = view.frame.size

        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
  
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
