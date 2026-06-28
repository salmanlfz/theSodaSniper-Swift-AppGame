//
//  BottleNode.swift
//  TheSodaSniper
//
//  Created by Antigravity on 28/06/26.
//

import SpriteKit

// Reusable component Botol menggunakan Sprite gambar dari Assets
class BottleNode: SKSpriteNode {
    var isBroken = false
    
    // Daftar nama aset botol yang ada di Assets.xcassets/bottles/
    static let bottleAssetNames = [
        "bottle-00", "bottle-01", "bottle-02", "bottle-03", "bottle-04", "bottle-05", "bottle-08",
        "bottle-12", "bottle-13", "bottle-14", "bottle-15", "bottle-16", "bottle-17", "bottle-18", "bottle-19", "bottle-20",
        "bottle-24", "bottle-25", "bottle-26", "bottle-27", "bottle-28", "bottle-29", "bottle-30", "bottle-31", "bottle-32", "bottle-33",
        "bottle-36", "bottle-37", "bottle-38", "bottle-39", "bottle-40", "bottle-41", "bottle-42", "bottle-43", "bottle-44", "bottle-45", "bottle-46", "bottle-47", "bottle-48", "bottle-49", "bottle-50", "bottle-51", "bottle-52", "bottle-53", "bottle-54", "bottle-55", "bottle-56", "bottle-57", "bottle-58", "bottle-59", "bottle-60", "bottle-61", "bottle-62", "bottle-63", "bottle-64", "bottle-65", "bottle-66", "bottle-67", "bottle-68", "bottle-69", "bottle-70", "bottle-71", "bottle-72", "bottle-73", "bottle-74", "bottle-75", "bottle-76", "bottle-77", "bottle-78", "bottle-79", "bottle-80", "bottle-81", "bottle-82", "bottle-83", "bottle-84", "bottle-85", "bottle-86", "bottle-87", "bottle-88", "bottle-89", "bottle-90", "bottle-91", "bottle-92", "bottle-93", "bottle-94", "bottle-95"
    ]
    
    init(imageName: String, size: CGSize) {
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) tidak diimplementasikan")
    }
    
    func breakBottle() {
        guard !isBroken else { return }
        isBroken = true
        
        // Hilangkan sprite botol utama dengan cepat
        run(SKAction.fadeOut(withDuration: 0.05))
        
        // Bikin serpihan kaca berwarna bening, hijau, cokelat, atau putih (berhamburan)
        let colors: [UIColor] = [
            UIColor(red: 0.85, green: 0.95, blue: 1.0, alpha: 0.7), // Kaca bening
            UIColor(red: 0.50, green: 0.75, blue: 0.50, alpha: 0.7), // Kaca hijau
            UIColor(red: 0.75, green: 0.55, blue: 0.35, alpha: 0.7), // Kaca cokelat
            .white
        ]
        
        for _ in 0..<10 {
            let shardSize = CGFloat.random(in: 3...7)
            let shard = SKShapeNode(rectOf: CGSize(width: shardSize, height: shardSize))
            shard.fillColor = colors.randomElement() ?? .white
            shard.strokeColor = .clear
            
            // Posisikan serpihan di pusat botol
            shard.position = CGPoint(
                x: CGFloat.random(in: -size.width/3...size.width/3),
                y: CGFloat.random(in: -size.height/3...size.height/3)
            )
            addChild(shard)
            
            // Gerakan berhamburan keluar & berputar
            let randomX = CGFloat.random(in: -45...45)
            let randomY = CGFloat.random(in: -20...50)
            let flyAction = SKAction.moveBy(x: randomX, y: randomY, duration: 0.3)
            let fadeAction = SKAction.fadeOut(withDuration: 0.3)
            let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: 0.3)
            
            let shardGroup = SKAction.group([flyAction, fadeAction, rotateAction])
            shard.run(SKAction.sequence([
                shardGroup,
                SKAction.removeFromParent()
            ]))
        }
        
        // Hapus node botol secara keseluruhan dari parent setelah serpihan beres
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.35),
            SKAction.removeFromParent()
        ]))
    }
    
    func checkHit(at point: CGPoint) -> Bool {
        guard !isBroken else { return false }
        // SpriteKit punya fungsi bawaan `.contains(point)` yang langsung
        // mendeteksi sentuhan frame bidikan!
        return self.contains(point)
    }
}
