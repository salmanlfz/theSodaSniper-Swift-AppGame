//
//  watchConnectivity.swift
//  Controller Watch App
//
//  Created by Salman on 23/06/26.
//

import Combine
import WatchConnectivity

class watchOSConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = watchOSConnectivity()
    
    @Published var message = ""
    
    override init(){
        super.init()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let message = message["message"] as? String {
                self.message = message
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendMessage(_ message: [String: Any]){
        if WCSession.default.isReachable {
            
            WCSession.default.sendMessage(message, replyHandler: nil , errorHandler: nil)
        }
    }
}
