//
//  SoundManager.swift
//  TheSodaSniper
//
//  Created by Salman on 27/06/26.
//

import AVFoundation

class SoundManager {
    
    // Singleton — satu instance buat seluruh app
    static let shared = SoundManager()
    
    // Player di-preload sekali, dipake berkali-kali
    private var shootPlayer: AVAudioPlayer?
    
    private init() {
        loadSounds()
    }
    
    private func loadSounds() {
        // Cari file "shoot-sfx.wav" di dalam bundle app
        guard let url = Bundle.main.url(
            forResource: "bottle-cap-shoot",
            withExtension: "wav"
        ) else {
            print("❌ File shoot-sfx.wav tidak ditemukan di bundle")
            return
        }
        
        do {
            shootPlayer = try AVAudioPlayer(contentsOf: url)
            // Preload ke memori — supaya gak ada delay waktu pertama kali play
            shootPlayer?.prepareToPlay()
            print("✅ shoot-sfx berhasil di-load")
        } catch {
            print("❌ Gagal load sound: \(error.localizedDescription)")
        }
    }
    
    func playShoot() {
        // currentTime = 0 supaya bisa ditrigger rapid fire
        // tanpa nunggu sound sebelumnya selesai
        shootPlayer?.currentTime = 0
        shootPlayer?.play()
    }
}
