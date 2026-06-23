//
//  motionControl.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import CoreMotion
import Combine

class MotionControl: NSObject, ObservableObject {
    var motionManager = CMMotionManager()
    
    @Published var roll: Double = 0
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    
    var degConvert = 180/Double.pi
    
    func readSensor(){
        if motionManager.isDeviceMotionAvailable {
            
            motionManager.deviceMotionUpdateInterval = 1.0/60.0
            
            motionManager.startDeviceMotionUpdates(to: .main) { (data, error) in
                if let data = data {
                    self.roll = data.attitude.roll * self.degConvert
                    self.pitch = data.attitude.pitch * self.degConvert
                    self.yaw = data.attitude.yaw * self.degConvert
                    
                    watchOSConnectivity.shared.sendMessage([
                        "roll": self.roll,
                        "pitch": self.pitch,
                        "yaw": self.yaw
                    ])
                }
                
            }
            
        }
    }
    
    func stopSensor(){
        motionManager.stopDeviceMotionUpdates()
    }
}
