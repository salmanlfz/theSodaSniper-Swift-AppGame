//
//  ControllerView.swift
//  Controller Watch App
//
//  Created by Salman on 23/06/26.
//

import SwiftUI

struct ControllerView: View {
    @ObservedObject var message = watchOSConnectivity.shared
    
    var body: some View {
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
}

#Preview {
    ControllerView()
}
