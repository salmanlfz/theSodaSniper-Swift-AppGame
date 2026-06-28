//
//  ShootingView.swift
//  TheSodaSniper
//
//  Created by Salman on 28/06/26.
//

import SwiftUI
import SpriteKit

struct ShootingView: View {
    // Tombol back untuk kembali ke Main Menu
    @Environment(\.dismiss) var dismiss
    
    // Kita gunakan state untuk melacak apakah user sudah melakukan kalibrasi pertama kali
    @State private var hasCalibrated = false
    
    // Scene SpriteKit yang akan kita mainkan
    @State private var gameScene: ShootingArenaScene?
    
    // Membaca data konektivitas Apple Watch
    @ObservedObject var connectivity = iOSConnectivity.shared
    
    var body: some View {
        ZStack {
            // 1. Tampilkan SpriteKit Game Scene jika kalibrasi sudah beres
            if let scene = gameScene, hasCalibrated {
                SpriteView(scene: scene)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                // Tombol Back saat bermain (melayang di pojok kiri atas)
                VStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Menu")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(20)
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
                        // Animasi Icon Apple Watch
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
                            dismiss()
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
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Paksa orientasi ke Landscape saat arena muncul
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            }
            
            // Matikan auto-sleep layar saat sedang bermain
            UIApplication.shared.isIdleTimerDisabled = true
            
            // Inisialisasi scene game
            let scene = ShootingArenaScene()
            let screenBounds = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds ?? CGRect(x: 0, y: 0, width: 800, height: 400)
            let width = max(screenBounds.width, screenBounds.height)
            let height = min(screenBounds.width, screenBounds.height)
            scene.size = CGSize(width: width, height: height)
            scene.scaleMode = .aspectFill
            self.gameScene = scene
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
    }
}

#Preview {
    ShootingView()
}
