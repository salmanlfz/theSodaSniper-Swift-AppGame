//
//  MainMenuVIew.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import SwiftUI

struct MainMenuVIew: View {
    @ObservedObject var message = iOSConnectivity.shared
    
    var body: some View {
        ZStack{
            Circle()
                .frame(width: 60, height: 60)
                .foregroundStyle(.cyan)
                .position(x: 0, y: 0)
            
            VStack{
                VStack{
                    Text("Roll: \(message.roll, specifier: "%.2f")")
                    Text("Pitch: \(message.pitch, specifier: "%.2f")")
                    Text("Yaw: \(message.yaw, specifier: "%.2f")")
                }
                
                HStack{
                    Button {
                        message.sendMessage(["message": "Hi from iphone"])
                    } label: {
                        Text("Hi")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        message.sendMessage(["message": "watch cupuuu"])
                    } label: {
                        Text("Boo")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                
                Text(message.message)
                
            }
        }

    }
}

#Preview {
    MainMenuVIew()
}
