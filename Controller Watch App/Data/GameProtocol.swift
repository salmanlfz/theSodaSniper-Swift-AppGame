//
//  GameProtocol.swift
//  Controller Watch App
//
//  Created by Salman on 26/06/26.
//

import Foundation

struct GameKeys {
    var pitch: Double = 0   // miring depan/belakang
    var roll: Double  = 0   // miring kiri/kanan
    var yaw: Double   = 0   // rotasi

    var isCalibrated: Bool = false

    var message: String = ""
}
