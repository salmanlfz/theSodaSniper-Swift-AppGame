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
    private var fireCooldown: TimeInterval = 0.5
    
    // 1. Variabel pendukung Filter IIR (Infinite Impulse Response)
    private var filteredRoll: Double = 0.0
    private var filteredPitch: Double = 0.0
    private var filteredYaw: Double = 0.0
    private let alpha: Double = 0.20 // Faktor smoothing (0.20: smooth, minim delay)
    
    // 2. Variabel offset hasil kalibrasi di sisi Watch
    private var calibratedRoll: Double = 0.0
    private var calibratedPitch: Double = 0.0
    private var calibratedYaw: Double = 0.0
    
    // 3. Flag request kalibrasi yang thread-safe
    private var isCalibratedRequest = false
    
    // 4. Counter agar update UI tidak membebani main thread
    private var uiUpdateCounter = 0
        
    override init() {
        super.init()
        // KABEL INI WAJIB ADA BIAR KURIR BISA NGASIH PAKET KE MANAJER!
        watchOSConnectivity.shared.motionManager = self
    }
    
    // Dipanggil dari UI Main Thread untuk trigger kalibrasi secara aman
    func triggerCalibration() {
        self.isCalibratedRequest = true
    }
    
    // 5. Piecewise function untuk deadzone getaran mikro & grafik sensitivitas akselerasi dinamis
    private func applyPiecewise(_ value: Double) -> Double {
        let absVal = abs(value)
        let deadzone = 0.01 // Abaikan tremor halus jari tangan
        
        if absVal < deadzone {
            return 0.0
        }
        
        let sign = value < 0 ? -1.0 : 1.0
        let adjustedVal = absVal - deadzone
        
        // Piecewise curve:
        // Gerakan kecil (sensitivitas lambat/halus untuk presisi membidik): dikali 0.7
        // Gerakan cepat (sensitivitas tinggi untuk mencakup jarak jauh): dikali 1.6
        if adjustedVal < 0.08 {
            return sign * (adjustedVal * 0.7)
        } else {
            return sign * (0.056 + (adjustedVal - 0.08) * 1.6)
        }
    }
    
    func readSensor() {
        if motionManager.isDeviceMotionAvailable {
            // Naikkan rate sensor ke 60Hz agar gerakan super halus dan responsif
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            
            // PENTING: Jalankan pembacaan di background queue agar tidak memblokir main UI thread
            let motionQueue = OperationQueue()
            motionQueue.name = "com.thesodasniper.motionQueue"
            motionQueue.qualityOfService = .userInteractive
            
            motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] (data, error) in
                guard let self = self, let data = data else { return }
                
                // Ambil nilai mentah orientasi berdasarkan gravitasi
                let rawRoll = data.gravity.x
                let rawPitch = data.gravity.y
                let rawYaw = data.gravity.z
                
                // 1. Terapkan IIR Smoothing Filter PERTAMA KALI pada sensor raw untuk meredam noise fisik
                self.filteredRoll = (self.alpha * rawRoll) + ((1.0 - self.alpha) * self.filteredRoll)
                self.filteredPitch = (self.alpha * rawPitch) + ((1.0 - self.alpha) * self.filteredPitch)
                self.filteredYaw = (self.alpha * rawYaw) + ((1.0 - self.alpha) * self.filteredYaw)
                
                // Cek pulse request kalibrasi (simpan offset dari data yang sudah disaring agar presisi)
                let isCalibrating = self.isCalibratedRequest
                if isCalibrating {
                    self.isCalibratedRequest = false
                    self.calibratedRoll = self.filteredRoll
                    self.calibratedPitch = self.filteredPitch
                    self.calibratedYaw = self.filteredYaw
                }
                
                // 2. Hitung penyimpangan relatif (instan, nol delay akumulasi!)
                let relativeRoll = self.filteredRoll - self.calibratedRoll
                let relativePitch = self.filteredPitch - self.calibratedPitch
                let relativeYaw = self.filteredYaw - self.calibratedYaw
                
                // 3. Terapkan Piecewise Function (Deadzone & Sensitivitas)
                var finalRoll = self.applyPiecewise(relativeRoll)
                var finalPitch = self.applyPiecewise(relativePitch)
                var finalYaw = self.applyPiecewise(relativeYaw)
                
                // Penyesuaian jika jam dipakai di tangan kanan (Right Wrist)
                if WKInterfaceDevice.current().wristLocation == .right {
                    finalRoll = -finalRoll
                    finalYaw = -finalYaw
                }
                
                // C. Deteksi hentakan tembakan (User Acceleration 3D - Akumulasi X, Y, Z)
                let accelX = data.userAcceleration.x
                let accelY = data.userAcceleration.y
                let accelZ = data.userAcceleration.z
                
                // Rumus Phytagoras 3D untuk mendapatkan total kekuatan hentakan tanpa peduli arah ayunan
                let totalAccel = sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ)
                
                let threshold = 0.58 // Kembalikan ke sensitivitas responsif (0.58) agar tembakan gampang dideteksi!
                var isFireDetected = false
                
                if totalAccel > threshold {
                    let now = Date()
                    if now.timeIntervalSince(self.lastFireTime) > self.fireCooldown {
                        self.lastFireTime = now
                        isFireDetected = true
                        
                        // Haptic feedback dimainkan asinkron di main thread
                        DispatchQueue.main.async {
                            WKInterfaceDevice.current().play(.notification)
                        }
                    }
                }
                
                // D. Kirim data ke iPhone SECARA INSTAN dari background thread (Nol Delay!)
                watchOSConnectivity.shared.sendMessage([
                    "roll": finalRoll,
                    "pitch": finalPitch,
                    "yaw": finalYaw,
                    "isCalibrated": isCalibrating,
                    "isFire": isFireDetected
                ])
                
                // E. Batasi update UI SwiftUI di Watch hanya 10Hz saja (tiap 6 frame)
                // Ini kunci agar CPU Apple Watch tetap dingin dan bluetooth lancar jaya!
                self.uiUpdateCounter += 1
                if self.uiUpdateCounter % 6 == 0 {
                    DispatchQueue.main.async {
                        // Tampilkan nilai fisik asli (absolut) di layar Watch agar tidak 0 (atau typo '9') semua setelah kalibrasi
                        self.localData.roll = self.filteredRoll
                        self.localData.pitch = self.filteredPitch
                        self.localData.yaw = self.filteredYaw
                        self.localData.accelX = totalAccel
                        self.localData.isFire = isFireDetected
                    }
                }
            }
        }
    }
    
    func stopSensor() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func receiveRemoteData(_ message: [String: Any]) {
        // Harus di main thread karena mengubah @Published
        DispatchQueue.main.async {
            if let msg = message["message"] as? String {
                self.remoteData.message = msg
            }
        }
    }
}
