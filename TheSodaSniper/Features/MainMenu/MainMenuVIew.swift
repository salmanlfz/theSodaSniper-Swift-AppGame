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
        VStack{
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

#Preview {
    MainMenuVIew()
}
