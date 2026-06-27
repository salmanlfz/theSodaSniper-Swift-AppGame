//
//  motionControl.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import CoreMotion
import Combine
import Foundation

class MotionControl: NSObject, ObservableObject {
    var motionManager = CMMotionManager()
    
    @Published var localData = LocalData()
    @Published var remoteData = RemoteData()
        
    override init() {
        super.init()
        // KABEL INI WAJIB ADA BIAR KURIR BISA NGASIH PAKET KE MANAJER!
        watchOSConnectivity.shared.motionManager = self
    }
    
    func readSensor(){
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0/60.0
            
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let data = data {
                    
                    self.localData.roll = data.gravity.x
                    self.localData.pitch = data.gravity.y
                    self.localData.yaw = data.gravity.z
                    
                    
                    watchOSConnectivity.shared.sendMessage([
                        "roll": self.localData.roll,
                        "pitch": self.localData.pitch,
                        "yaw": self.localData.yaw,
                        "message": self.localData.message,
                        "isCalibrated": self.localData.isCalibrated
                    ])
                    print(self.localData.isCalibrated)
                    
                    self.localData.isCalibrated = false
                    
                    print(self.localData.isCalibrated)
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
                self.remoteData.message = message["message"] as! String
            }
        }
}
