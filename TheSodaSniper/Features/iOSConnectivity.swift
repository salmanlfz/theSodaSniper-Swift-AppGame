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
        let bounds = windowScene.screen.bounds
        return max(bounds.width, bounds.height)
    }
    
    var screenHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return 400 }
        let bounds = windowScene.screen.bounds
        return min(bounds.width, bounds.height)
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
                    
                    // Kirim notifikasi kalau kalibrasi selesai!
                    NotificationCenter.default.post(name: NSNotification.Name("WatchDidCalibrate"), object: nil)
                }
            }
            if let isFire = message["isFire"] as? Bool {
                self.remoteData.isFire = isFire
                
                if self.remoteData.isFire {
                    SoundManager.shared.playShoot()
                    // Kirim notifikasi kalau watch nembak!
                    NotificationCenter.default.post(name: NSNotification.Name("WatchDidFire"), object: nil)
                }
            }
            
            print("kalibrasi dh: \(self.remoteData.isCalibrated)")
            print("tembak ga dh: \(self.remoteData.isFire)")
        
            // Karena Watch sudah mengirim data relatif (sudah dikalibrasi di sisi Watch),
            // kita tidak perlu melakukan pengurangan ganda di sini agar bidikan tidak meleset!
            let rawX = self.remoteData.roll
            let rawZ = self.remoteData.yaw
            
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
