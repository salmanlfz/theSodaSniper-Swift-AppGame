//
//  GameProtocol.swift
//  Controller Watch App
//
//  Created by Salman on 25/06/26.
//

import Foundation

// Data yang dikirim iPhone ke Watch (dari luar)
// Contoh: posisi target, skor, perintah haptic, dll
struct LocalData {
    var message: String     = ""
    
    var calibratedPitch: Double = 0   // miring depan/belakang
    var calibratedRoll: Double  = 0   // miring kiri/kanan
    var calibratedYaw: Double   = 0   // rotasi
    
    var dotX: CGFloat = 0
    var dotY: CGFloat = 0
    
    
}

// Data dari sensor Watch sendiri (lokal)
struct RemoteData {
    var pitch: Double = 0   // miring depan/belakang
    var roll: Double  = 0   // miring kiri/kanan
    var yaw: Double   = 0   // rotasi

    var isCalibrated: Bool = false

    var message: String = ""
    
    var accelX : Double = 0
    var accelZ : Double = 0
    
    var isFire: Bool = false
}

