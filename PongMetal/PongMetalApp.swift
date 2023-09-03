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
                    
                Menu("Resolution") {
                    
                    Button("320x180") {
                        GameSetup.gameWidth = 320
                        GameSetup.gameHeight = 180
                        NotificationCenter.default.post(name: GameSetup.resolutionChangedEvent, object: self)
                    }
                    
                    Button("640x360") {
                        GameSetup.gameWidth = 640
                        GameSetup.gameHeight = 360
                        NotificationCenter.default.post(name: GameSetup.resolutionChangedEvent, object: self)
                    }
                    
                    Button("1280x720") {
                        GameSetup.gameWidth = 1280
                        GameSetup.gameHeight = 720
                        NotificationCenter.default.post(name: GameSetup.resolutionChangedEvent, object: self)
                    }
                    Button("1920x1080") {
                        GameSetup.gameWidth = 1920
                        GameSetup.gameHeight = 1080
                        NotificationCenter.default.post(name: GameSetup.resolutionChangedEvent, object: self)
                    }
                    Button("2560x1440") {
                        GameSetup.gameWidth = 2560
                        GameSetup.gameHeight = 1440
                        NotificationCenter.default.post(name: GameSetup.resolutionChangedEvent, object: self)
                    }
                
                }
    
                    Toggle(isOn: $splitScreen ) {
                        Text("Split Screen")
                    }
                    .toggleStyle(.checkbox)
         
                    ColorPicker("Background color: ", selection: $backgroundColor)
                
                    ColorPicker("Left paddle color: ", selection: $leftPaddleColor)
                    
    
                    ColorPicker("Right paddle color: ", selection: $rightPaddleColor)

                    ColorPicker("Ball color: ", selection: $ballColor)
                }
            .frame(minWidth: 200,
                   maxWidth: 200,
                   minHeight: 720,
                   maxHeight: 720,
                   alignment: .topLeading)
            .padding(10)

            
            ContentView(
                backgroundColor: $backgroundColor,
                leftPaddleColor: $leftPaddleColor,
                rightPaddleColor: $rightPaddleColor,
                ballColor: $ballColor,
                splitScreen: $splitScreen
            ).frame(width: GameSetup.frameWidth, height: GameSetup.frameHeight, alignment: .center)
        
        }
    }
}


struct App_Previews: PreviewProvider {
    static var previews: some View {
        MainContent()
    }
}
