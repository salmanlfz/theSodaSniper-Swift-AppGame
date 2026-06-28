//
//  ControllerView.swift
//  Controller Watch App
//
//  Created by Salman on 23/06/26.
//

import SwiftUI

struct ControllerView: View {
    @ObservedObject var message = watchOSConnectivity.shared
    @ObservedObject var sensor = MotionManager()
    
    var body: some View {
        TabView{
            VStack{
                Text("Roll: \(sensor.localData.roll, specifier: "%.2f")")
                Text("Pitch: \(sensor.localData.pitch, specifier: "%.2f")")
                Text("Yaw: \(sensor.localData.yaw, specifier: "%.2f")")
                
                Button {
                    sensor.localData.isCalibrated = true
                } label: {
                    Text("Calibrate")
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            
            VStack{
                HStack{
                    Button {
                        sensor.localData.message = "Hi from watch"
                    } label: {
                        Text("Hi")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        sensor.localData.message = "iphone cupu"
                    } label: {
                        Text("Boo")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                
                Text(sensor.remoteData.message)
                
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
