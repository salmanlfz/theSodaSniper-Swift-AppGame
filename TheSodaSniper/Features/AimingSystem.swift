//
//  Aiming.swift
//  TheSodaSniper
//
//  Created by Salman on 27/06/26.
//

import Combine
import UIKit

class AimingSystem: ObservableObject {
    let screen: UIScreen
    @Published var dotX: CGFloat
    @Published var dotY: CGFloat
    
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    init(screen: UIScreen) {
        self.screen = screen
        self.dotX = screen.bounds.width / 2
        self.dotY = screen.bounds.height / 2
        self.screenWidth = screen.bounds.width
        self.screenHeight = screen.bounds.height
    }
    
    func processAiming(rawZ: Double, rawX: Double){
        let gain: CGFloat = 400.0
        
        let calculatedX = (gain * CGFloat(rawZ)) + (screen.bounds.width/2)
        let calculatedY = (gain * CGFloat(rawX)) + (screen.bounds.height/2)
        
        let finalX = min(max(calculatedX, 0), screen.bounds.width)
        let finalY = min(max(calculatedY, 0), screen.bounds.height)
        
        self.dotX = finalX
        self.dotY = finalY

    }
//    func XlinearTransform(coordinat: Double){
//        var coordinat: Double = 0.0
//        
//        let gain = 1.0
//        let zeroPoint = width/2
//        
//        // y = mx + c
//        var y = (gain * coordinat) + zeroPoint
//    }
//    
//    func YlinearTransform(coordinat: Double){
//        var coordinat: Double = 0.0
//        
//        let gain = 1.0
//        let zeroPoint = height/2
//        
//        // y = mx + c
//        var y = (gain * coordinat) + zeroPoint
//    }
//
//    
//    func clamping(x:Double, y:Double){
//        var y:Double = 0.0
//        var x:Double = 0.0
//        
//        let batasAtasY = height
//        let batasBawahY = 0.0
//        
//        let batasAtasX = width
//        let batasBawahX = 0.0
//        
//        var Yfinal = min(max(y, batasBawahY), batasAtasY)
//        var Xfinal = min(max(x, batasBawahX), batasAtasX)
//    }
}

