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
        GeometryReader{ geometry in
            ZStack{
                VStack{
                    VStack{
                        Text("Roll: \(message.remoteData.roll, specifier: "%.2f")")
                        Text("Pitch: \(message.remoteData.pitch, specifier: "%.2f")")
                        Text("Yaw: \(message.remoteData.yaw, specifier: "%.2f")")
                    }
                    
                    HStack{
                        VStack{
                            Text("Calibration")
                            Text("Roll: \(message.localData.calibratedRoll, specifier: "%.2f")")
                            Text("Pitch: \(message.localData.calibratedPitch, specifier: "%.2f")")
                            Text("Yaw: \(message.localData.calibratedYaw, specifier: "%.2f")")
                        }
                        .padding(16)
                        .background()
                        .cornerRadius(12)
                        
                        Button {
                            message.localData.message = "Hi from iphone"
                            message.sendMessage(["message": message.localData.message])
                        } label: {
                            Text("Hi")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            message.localData.message = "watch cupuuu"
                            message.sendMessage(["message": message.localData.message])
                        } label: {
                            Text("Boo")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    
                    Text(message.remoteData.message)
                    
                }
                .padding(16)
                .background(.gray.opacity(0.5))
                .cornerRadius(12)
                
                Circle()
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.cyan)
                    .position(
                        x: message.localData.dotX,
                        y: message.localData.dotY
                    )
            }
            // 1. NYALAKAN SAAT LAYAR GAME MUNCUL
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            // 2. MATIKAN SAAT LAYAR GAME DITUTUP / PINDAH MENU
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }

    }
}

#Preview {
    MainMenuVIew()
}
