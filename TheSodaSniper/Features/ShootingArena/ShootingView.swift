//
//  ShootingView.swift
//  TheSodaSniper
//
//  Created by Salman on 28/06/26.
//

import SwiftUI
import SpriteKit

struct ShootingView: View {
    // Callback closure untuk menutup arena dan kembali ke Menu Utama di parent view
    var onExit: () -> Void
    
    // Kita gunakan state untuk melacak apakah user sudah melakukan kalibrasi pertama kali
    @State private var hasCalibrated = false
    
    // State untuk melacak status game over & total skor
    @State private var isGameOver = false
    @State private var totalScore = 0
    
    // State untuk mengaktifkan pop-up konfirmasi keluar game
    @State private var showExitAlert = false
    
    // State ID dinamis untuk memaksa re-render SpriteView saat game reset
    @State private var sceneID = UUID()
    
    // Scene SpriteKit yang akan kita mainkan
    @State private var gameScene: ShootingArenaScene?
    
    // Membaca data konektivitas Apple Watch
    @ObservedObject var connectivity = iOSConnectivity.shared
    
    var body: some View {
        ZStack {
            // 1. Tampilkan SpriteKit Game Scene jika kalibrasi sudah beres
            if let scene = gameScene, hasCalibrated {
                SpriteView(scene: scene)
                    .id(sceneID) // Memaksa SwiftUI membuat ulang SKView baru saat sceneID berubah (Reset Game!)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                // Tombol Back saat bermain (melayang di pojok kiri atas) - Didesain ala Kartun / Neobrutalism
                VStack {
                    HStack {
                        Button {
                            showExitAlert = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "house") // Icon bentuk stack menu
                                    .font(.system(size: 16, weight: .black))
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(Color.yellow) // Kuning kartun yang kontras
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 3) // Border hitam tebal ala kartun/komik
                            )
                            .shadow(color: .black.opacity(0.35), radius: 0, x: 3, y: 3) // Bayangan tajam 2D
                        }
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.top, 20)
                
            } else {
                // 2. Tampilan Panduan Kalibrasi (Calibrate Dulu) sebelum game dimulai
                ZStack {
                    // Gunakan background gambar buram agar kelihatan estetik
                    Image("shooting-bg")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea()
                        .blur(radius: 8)
                        .overlay(Color.black.opacity(0.65))
                    
                    VStack(spacing: 25) {
                        // Icon Apple Watch
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 4)
                                .frame(width: 90, height: 90)
                                .scaleEffect(connectivity.remoteData.isCalibrated ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: hasCalibrated)
                            
                            Image(systemName: "applewatch.radiowaves.left.and.right")
                                .font(.system(size: 45))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 10) {
                            Text("WATCH CALIBRATION")
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.black)
                                .foregroundColor(.white)
                                .tracking(2)
                            
                            Text("Point your hand straight at the screen, then press the 'Calibrate' button on your Apple Watch.")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineSpacing(4)
                        }
                        
                        // Status menanti kalibrasi
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            Text("Waiting for calibration...")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(12)
                        
                        // Tombol kembali ke main menu jika batal bermain
                        Button {
                            onExit()
                        } label: {
                            Text("Kembali ke Menu")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 10)
                    }
                    .padding(30)
                }
                .transition(.opacity)
            }
            
            // 3. Tampilan Overlay Game Selesai (Bravoo! & You did it!)
            if isGameOver {
                ZStack {
                    // Latar belakang hitam transparan
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                    
                    VStack(spacing: 18) {
                        Text("BRAVOO! 🎉")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.orange)
                            .tracking(3)
                            .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Text("You did it!")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("TOTAL SCORE: \(totalScore)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.yellow)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.vertical, 5)
                        
                        HStack(spacing: 20) {
                            // Tombol Kembali ke Menu Utama
                            Button {
                                onExit()
                            } label: {
                                Text("Main Menu")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 14)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(20)
                            }
                            
                            // Tombol Play Again (Mulai Ulang)
                            Button {
                                resetGame()
                            } label: {
                                Text("Play Again")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 35)
                                    .padding(.vertical, 14)
                                    .background(Color.orange)
                                    .cornerRadius(20)
                                    .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(35)
                    .background(Color(white: 0.08).opacity(0.95))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
                    )
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
                .zIndex(10) // Pastikan ditaruh di layer terdepan
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Paksa orientasi ke Landscape saat arena muncul
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            }
            
            // Matikan auto-sleep layar saat sedang bermain
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Inisialisasi scene game pertama kali
            initializeGameScene()
        }
        .onDisappear {
            // Nyalakan kembali auto-sleep layar saat keluar game
            UIApplication.shared.isIdleTimerDisabled = false
        }
        // Mendengarkan notifikasi kalibrasi sukses dari Apple Watch
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("WatchDidCalibrate"))) { _ in
            withAnimation(.spring()) {
                self.hasCalibrated = true
            }
        }
        // Alert konfirmasi ketika user memencet tombol MENU saat permainan sedang berlangsung
        .alert("Back to Menu?", isPresented: $showExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                onExit()
            }
        } message: {
            Text("Are you sure you want to quit? Your progress in this game will be lost.")
        }
    }
    
    // Fungsi untuk setup/inisialisasi game scene
    private func initializeGameScene() {
        let scene = ShootingArenaScene()
        let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 800, height: 400)
        let width = max(screenBounds.width, screenBounds.height)
        let height = min(screenBounds.width, screenBounds.height)
        
        scene.size = CGSize(width: width, height: height)
        scene.scaleMode = .aspectFill
        
        // Pasang callback ketika semua botol berhasil dipecahkan!
        scene.onGameOver = { finalScore in
            withAnimation(.spring()) {
                self.totalScore = finalScore
                self.isGameOver = true
            }
        }
        
        self.gameScene = scene
        self.sceneID = UUID() // Perbarui ID agar SpriteView di-refresh secara paksa!
    }
    
    // Mulai ulang permainan (reset game state)
    private func resetGame() {
        withAnimation {
            isGameOver = false
        }
        // Re-inisialisasi game scene baru
        initializeGameScene()
    }
}

#Preview {
    ShootingView(onExit: {})
}
