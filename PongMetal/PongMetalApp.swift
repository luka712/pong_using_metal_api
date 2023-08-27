//
//  PongMetalApp.swift
//  PongMetal
//
//  Created by Luka Erkapic on 20.08.23.
//

import SwiftUI

@main
struct PongMetalApp: App {
    
 
    
    var body: some Scene {
        WindowGroup {
           MainContent()
        
        }
    }
}

struct MainContent : View
{
    @State private var backgroundColor = Color.cyan
    @State private var leftPaddleColor = Color.red
    @State private var rightPaddleColor = Color.blue
    
    var body: some View {
        HStack {
            
            VStack {
                Spacer()
                    .frame(height: 20)
                ColorPicker("Background color: ", selection: $backgroundColor)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Left paddle color: ", selection: $leftPaddleColor)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Right paddle color: ", selection: $rightPaddleColor)
            }
            .frame(width: 200, alignment: .topLeading)
            .padding(5)

            
            ContentView(
                backgroundColor: $backgroundColor,
                leftPaddleColor: $leftPaddleColor,
                rightPaddleColor: $rightPaddleColor
            ).frame(width: GameSetup.gameWidth, height: GameSetup.gameHeight)
                
           
        }
    }
}


struct App_Previews: PreviewProvider {
    static var previews: some View {
        MainContent()
    }
}
