//
//  motionControl.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import CoreMotion
import Combine
import Foundation
import WatchKit

class MotionManager: NSObject, ObservableObject {
    var motionManager = CMMotionManager()
    
    @Published var localData = LocalData()
    @Published var remoteData = RemoteData()
    
    private var lastFireTime: Date = Date()
    private var fireCooldown: TimeInterval = 0.1
        
    override init() {
        super.init()
        // KABEL INI WAJIB ADA BIAR KURIR BISA NGASIH PAKET KE MANAJER!
        watchOSConnectivity.shared.motionManager = self
    }
    
    func readSensor(){
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0/30.0
            
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let data = data {
                    
                    self.localData.roll = data.gravity.x
                    self.localData.pitch = data.gravity.y
                    self.localData.yaw = data.gravity.z
                    
                    self.localData.accelX = data.userAcceleration.x
                    self.localData.accelZ = data.userAcceleration.z
                    
                    let threshold = 0.5
                    
                    if self.localData.accelX > threshold {
                        let now = Date()
                        
                        if now.timeIntervalSince(self.lastFireTime) > self.fireCooldown {
                            self.lastFireTime = now
                            self.localData.isFire = true
                            
                            WKInterfaceDevice.current().play(.notification)
                        }
                    }
                    
                    watchOSConnectivity.shared.sendMessage([
                        "roll": self.localData.roll,
                        "pitch": self.localData.pitch,
                        "yaw": self.localData.yaw,
                        "message": self.localData.message,
                        "isCalibrated": self.localData.isCalibrated,
                        "isFire": self.localData.isFire
                    ])
//                    print(self.localData.isCalibrated)
                    
                    self.localData.isCalibrated = false
                    self.localData.isFire = false
                    self.localData.message = ""
                    
//                    print(self.localData.isCalibrated)
                }
                
            }
            
        }
    }
    
    func stopSensor(){
        motionManager.stopDeviceMotionUpdates()
    }
    
    func receiveRemoteData(_ message: [String: Any]) {
        // Harus di main thread karena ngubah @Published
        DispatchQueue.main.async {
//                self.remoteData = data
            if let msg = message["message"] as? String {
                self.remoteData.message = msg
            }
        }
    }
}
