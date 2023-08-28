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
    @State private var splitScreen = false
    @State private var backgroundColor = Color.cyan
    @State private var leftPaddleColor = Color.red
    @State private var rightPaddleColor = Color.blue
    @State private var ballColor = Color.white
    
    
    
    var body: some View {

        HStack {
            
            VStack {
                
                Spacer()
                    .frame(height: 20)
                Toggle(isOn: $splitScreen ) {
                    Text("Split Screen")
                }
                .toggleStyle(.checkbox)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Background color: ", selection: $backgroundColor)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Left paddle color: ", selection: $leftPaddleColor)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Right paddle color: ", selection: $rightPaddleColor)
                
                Spacer()
                    .frame(height: 20)
                ColorPicker("Ball color: ", selection: $ballColor)
            }
            .frame(minWidth: 200,
                   maxWidth: 200,
                   minHeight: 720,
                   maxHeight: 720,
                   alignment: .topLeading)
            .padding(5)

            
            ContentView(
                backgroundColor: $backgroundColor,
                leftPaddleColor: $leftPaddleColor,
                rightPaddleColor: $rightPaddleColor,
                ballColor: $ballColor,
                splitScreen: $splitScreen
            ).frame(width: GameSetup.gameWidth, height: GameSetup.gameHeight)
        }
    }
}


struct App_Previews: PreviewProvider {
    static var previews: some View {
        MainContent()
    }
}
