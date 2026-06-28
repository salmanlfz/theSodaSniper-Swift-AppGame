//
//  ShootingArenaScene.swift
//  TheSodaSniper
//
//  Created by Antigravity on 28/06/26.
//

import SpriteKit
import SwiftUI

class ShootingArenaScene: SKScene {
    // Target bidikan (crosshair)
    var crosshair: SKSpriteNode!
    
    // List botol yang sedang aktif di arena
    var bottles: [BottleNode] = []
    
    // Label untuk nampilin skor
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        // 1. Set background menggunakan gambar "shooting-bg"
        let background = SKSpriteNode(imageNamed: "shooting-bg")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        
        // Sesuaikan ukuran background agar memenuhi layar
        let scaleX = size.width / background.size.width
        let scaleY = size.height / background.size.height
        let scale = max(scaleX, scaleY)
        background.setScale(scale)
        background.zPosition = -1 // Paling belakang
        addChild(background)
        
        // 2. Bikin Label Skor (Di Pojok Kanan Atas)
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: size.width - 30, y: size.height - 50)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        
        // 3. Tambahkan Crosshair (Kekeran)
        // Kita pakai aset gambar "Image" (karena folder asset kita bernama Image)
        crosshair = SKSpriteNode(imageNamed: "Image")
        crosshair.size = CGSize(width: 50, height: 50)
        crosshair.position = CGPoint(x: size.width / 2, y: size.height / 2)
        crosshair.zPosition = 100 // Paling depan
        addChild(crosshair)
        
        // 4. Spawn rak dan botol-botolnya
        spawnBottles()
        
        // 5. Daftarkan notifikasi ketika Apple Watch menembak
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveFireNotification),
            name: NSNotification.Name("WatchDidFire"),
            object: nil
        )
    }
    
    // Fungsi untuk memposisikan rak dan botol secara dinamis
    func spawnBottles() {
        // Hapus botol lama jika ada
        for bottle in bottles {
            bottle.removeFromParent()
        }
        bottles.removeAll()
        
        // Kita taruh di 3 tingkat ketinggian rak (30%, 55%, dan 80% dari tinggi layar)
        let shelfYPositions = [size.height * 0.30, size.height * 0.55, size.height * 0.80]
        let bottleTypes = ["cola", "beer", "soda"]
        
        for y in shelfYPositions {
            // Gambar garis rak warna kayu cokelat
            let shelfWidth = size.width * 0.85
            let shelf = SKShapeNode(rectOf: CGSize(width: shelfWidth, height: 12), cornerRadius: 3)
            shelf.fillColor = UIColor(red: 0.40, green: 0.25, blue: 0.15, alpha: 1.0)
            shelf.strokeColor = .white
            shelf.lineWidth = 1.0
            shelf.position = CGPoint(x: size.width / 2, y: y)
            shelf.zPosition = 1
            addChild(shelf)
            
            // Tempatkan 4 botol di atas setiap rak
            let spacing = shelfWidth / 5
            let startX = (size.width / 2) - (shelfWidth / 2)
            
            for i in 1...4 {
                let randomImageName = BottleNode.bottleAssetNames.randomElement() ?? "bottle-00"
                // Ukuran asli botol agar tampak proporsional: Lebar: 28, Tinggi: 68
                let bottle = BottleNode(imageName: randomImageName, size: CGSize(width: 56, height: 68))
                
                // Letakkan pas di atas rak (+ 6 untuk setengah tebal rak, + 34 untuk setengah tinggi botol)
                bottle.position = CGPoint(x: startX + CGFloat(i) * spacing, y: y + 30)
                bottle.zPosition = 2
                addChild(bottle)
                
                bottles.append(bottle)
            }
        }
    }
    
    // Dipanggil saat notifikasi tembakan dari Watch masuk
    @objc func didReceiveFireNotification() {
        shoot()
    }
    
    func shoot() {
        // 1. Animasi efek kilatan cahaya tembakan di titik crosshair
        let flash = SKShapeNode(circleOfRadius: 18)
        flash.fillColor = .yellow
        flash.strokeColor = .white
        flash.lineWidth = 2
        flash.position = crosshair.position
        flash.zPosition = 90
        addChild(flash)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([fadeOut, remove]))
        
        // 2. Cek apakah ada botol yang kena tembak di posisi crosshair
        for bottle in bottles {
            if bottle.checkHit(at: crosshair.position) {
                // Pecahkan botol!
                bottle.breakBottle()
                SoundManager.shared.playBreak() // Putar SFX botol pecah!
                score += 10
                
                // Cek apakah semua botol sudah habis pecah
                checkWinCondition()
                break // Cukup pecahkan 1 botol per tembakan
            }
        }
    }
    
    func checkWinCondition() {
        // Hitung botol yang tersisa
        let activeBottles = bottles.filter { !$0.isBroken }
        if activeBottles.isEmpty {
            // Semua botol pecah! Tunggu 1.2 detik terus spawn rak baru biar mainnya seru terus!
            let wait = SKAction.wait(forDuration: 1.2)
            let respawn = SKAction.run { [weak self] in
                self?.spawnBottles()
            }
            run(SKAction.sequence([wait, respawn]))
        }
    }
    
    // SpriteKit update loop (dipanggil otomatis tiap frame)
    override func update(_ currentTime: TimeInterval) {
        // 1. Ambil koordinat aiming dari Apple Watch (melalui iOSConnectivity)
        let targetX = iOSConnectivity.shared.localData.dotX
        let targetY = iOSConnectivity.shared.localData.dotY
        
        // 2. Karena SwiftUI (0,0) di kiri-atas sedangkan SpriteKit (0,0) di kiri-bawah,
        // kita balik sumbu Y nya biar pas membidik.
        let correctedY = size.height - targetY
        
        // 3. Posisikan crosshair ke target bidikan secara langsung
        crosshair.position = CGPoint(x: targetX, y: correctedY)
    }
    
    // Jangan lupa hapus observer saat scene dihancurkan agar memori aman
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
