//
//  GameProtocol.swift
//  Controller Watch App
//
//  Created by Salman on 25/06/26.
//

import Foundation

// Data dari sensor Watch sendiri (lokal)
struct LocalData {
    var pitch: Double = 0   // miring depan/belakang
    var roll: Double  = 0   // miring kiri/kanan
    var yaw: Double   = 0   // rotasi

    var isCalibrated: Bool = false

    var message: String = ""
}

// Data yang dikirim iPhone ke Watch (dari luar)
// Contoh: posisi target, skor, perintah haptic, dll
struct RemoteData {
//    var targetX: Double     = 0      // posisi target di layar iPhone
//    var targetY: Double     = 0
//    var score: Int          = 0
//    var shouldVibrate: Bool = false  // perintah haptic dari iPhone
    var message: String     = ""
}
