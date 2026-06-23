//
//  iOSConnectivity.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import Combine
import WatchConnectivity

class iOSConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = iOSConnectivity()
    
    @Published var message = ""
    
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    
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
            if let roll = message["roll"] as? Double {
                self.roll = roll
            }
            if let pitch = message["pitch"] as? Double {
                self.pitch = pitch
            }
            if let yaw = message["yaw"] as? Double {
                self.yaw = yaw
            }
        
        }
    
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sendMessage(_ message: [String: Any]){
        if WCSession.default.isReachable {
            
            WCSession.default.sendMessage(message, replyHandler: nil , errorHandler: nil)
        }
    }
}
