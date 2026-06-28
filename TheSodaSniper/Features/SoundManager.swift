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
    private var breakPlayer: AVAudioPlayer?
    private var bgmPlayer: AVAudioPlayer?
    
    private init() {
        loadSounds()
    }
    
    private func loadSounds() {
        // 1. Load sound tembak
        if let shootUrl = Bundle.main.url(forResource: "bottle-cap-shoot", withExtension: "wav") {
            do {
                shootPlayer = try AVAudioPlayer(contentsOf: shootUrl)
                shootPlayer?.prepareToPlay()
                print("✅ bottle-cap-shoot berhasil di-load")
            } catch {
                print("❌ Gagal load shoot sound: \(error.localizedDescription)")
            }
        } else {
            print("❌ File bottle-cap-shoot.wav tidak ditemukan di bundle")
        }
        
        // 2. Load sound botol pecah
        if let breakUrl = Bundle.main.url(forResource: "broken-bottle", withExtension: "wav") {
            do {
                breakPlayer = try AVAudioPlayer(contentsOf: breakUrl)
                breakPlayer?.prepareToPlay()
                print("✅ broken-bottle berhasil di-load")
            } catch {
                print("❌ Gagal load break sound: \(error.localizedDescription)")
            }
        } else {
            print("❌ File broken-bottle.wav tidak ditemukan di bundle")
        }
        
        // 3. Load background music (BGM)
        if let bgmUrl = Bundle.main.url(forResource: "bg-music", withExtension: "wav") {
            do {
                bgmPlayer = try AVAudioPlayer(contentsOf: bgmUrl)
                bgmPlayer?.numberOfLoops = -1 // Looping selamanya
                bgmPlayer?.volume = 0.25 // Volume agak dikecilkan biar gak nutupin SFX tembak/pecah
                bgmPlayer?.prepareToPlay()
                print("✅ bg-music berhasil di-load")
            } catch {
                print("❌ Gagal load bg-music: \(error.localizedDescription)")
            }
        } else {
            print("❌ File bg-music.wav tidak ditemukan di bundle")
        }
    }
    
    func playShoot() {
        // currentTime = 0 supaya bisa ditrigger rapid fire
        // tanpa nunggu sound sebelumnya selesai
        shootPlayer?.currentTime = 0
        shootPlayer?.play()
    }
    
    func playBreak() {
        // Reset time agar bisa diputar tumpang tindih dengan cepat
        breakPlayer?.currentTime = 0
        breakPlayer?.play()
    }
    
    func playBGM() {
        guard let player = bgmPlayer, !player.isPlaying else { return }
        player.play()
    }
    
    func stopBGM() {
        bgmPlayer?.stop()
    }
    
    func pauseBGM() {
        bgmPlayer?.pause()
    }
}
