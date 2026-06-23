//
//  ControllerView.swift
//  Controller Watch App
//
//  Created by Salman on 23/06/26.
//

import SwiftUI

struct ControllerView: View {
    @ObservedObject var message = watchOSConnectivity.shared
    @ObservedObject var sensor = MotionControl()
    
    var body: some View {
        TabView{
            VStack{
                Text("Roll: \(sensor.roll, specifier: "%.2f")")
                Text("Pitch: \(sensor.pitch, specifier: "%.2f")")
                Text("Yaw: \(sensor.yaw, specifier: "%.2f")")
            }
            
            VStack{
                HStack{
                    Button {
                        message.sendMessage(["message": "Hi from watch"])
                    } label: {
                        Text("Hi")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        message.sendMessage(["message": "iphone cupuuu"])
                    } label: {
                        Text("Boo")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                
                Text(message.message)
                
            }
        }
        .onAppear {
            sensor.readSensor()
        }
        .onDisappear {
            sensor.stopSensor()
        }
    }
}

#Preview {
    ControllerView()
}
