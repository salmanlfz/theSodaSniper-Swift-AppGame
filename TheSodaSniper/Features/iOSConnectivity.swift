//
//  iOSConnectivity.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import Combine
import WatchConnectivity
import UIKit

class iOSConnectivity: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = iOSConnectivity()
    
    @Published var localData = LocalData()
    @Published var remoteData = RemoteData()
    
    var screenWidth: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return 800 }
        return windowScene.screen.bounds.width
    }
    
    var screenHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return 400 }
        return windowScene.screen.bounds.height
    }

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
                self.remoteData.message = message
            }
            if let roll = message["roll"] as? Double {
                self.remoteData.roll = roll
            }
            if let pitch = message["pitch"] as? Double {
                self.remoteData.pitch = pitch
            }
            if let yaw = message["yaw"] as? Double {
                self.remoteData.yaw = yaw
            }
            if let isCalibrated = message["isCalibrated"] as? Bool {
                self.remoteData.isCalibrated = isCalibrated
                
                
                if self.remoteData.isCalibrated {
                    self.localData.calibratedRoll = self.remoteData.roll
                    self.localData.calibratedPitch = self.remoteData.pitch
                    self.localData.calibratedYaw = self.remoteData.yaw
                }
            }
            if let isFire = message["isFire"] as? Bool {
                self.remoteData.isFire = isFire
                
                if self.remoteData.isFire {
                    // Di dalam file iOSConnectivity atau View lu pas nangkep trigger tembak:
                    SoundManager.shared.playShoot()
                }
            }
            
            print("kalibrasi dh: \(self.remoteData.isCalibrated)")
            print("tembak ga dh: \(self.remoteData.isFire)")
        
            let rawX = self.remoteData.roll - self.localData.calibratedRoll
            let rawZ = self.remoteData.yaw - self.localData.calibratedYaw
            
            self.processAiming(rawZ: rawZ, rawX: rawX)
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
        
    func processAiming(rawZ: Double, rawX: Double){
        let gainX: CGFloat = 1600.0
        let gainY: CGFloat = 400.0
        
        let calculatedX = (gainX * CGFloat(rawZ)) + (screenWidth/2)
        let calculatedY = (gainY * CGFloat(rawX)) + (screenHeight/2)
        
        let finalX = min(max(calculatedX, 0), screenWidth)
        let finalY = min(max(calculatedY, 0), screenHeight)
        
        localData.dotX = finalX
        localData.dotY = finalY

    }
}
