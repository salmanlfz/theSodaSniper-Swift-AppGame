//
//  MainMenuView.swift
//  TheSodaSniper
//
//  Created by Salman on 23/06/26.
//

import SwiftUI

struct MainMenuView: View {
    // Inisialisasi konektivitas di awal biar terhubung ke Apple Watch
    @StateObject private var connectivity = iOSConnectivity.shared
    
    // State untuk perpindahan ke view game
    @State private var isPlaying = false
    
    // State untuk animasi tombol menu
    @State private var animateButton = false
    
    var body: some View {
        if isPlaying {
            // Buka arena bermain
            ShootingView(onExit: {
                withAnimation(.spring()) {
                    isPlaying = false
                }
            })
                .transition(.opacity)
        } else {
            ZStack {
                // 1. Background Gambar yang di-blur & Gelap (Landscape Fit)
                Image("shooting-bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .blur(radius: 5)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.85),
                                Color.black.opacity(0.4),
                                Color.black.opacity(0.85)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // 2. Konten Menu Utama (Didesain Khusus untuk Landscape!)
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 32)
                    
                    // Bagian Kiri: Logo Target dan Judul Game
                    VStack(spacing: 10) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(2)
                        
                        Spacer()
                            .frame(height: 16)
                        
                        // Status koneksi jam di pojok kiri bawah
                        HStack(spacing: 6) {
                            Circle()
                                .fill(connectivity.remoteData.pitch != 0 ? Color.green : Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text(connectivity.remoteData.pitch != 0 ? "Apple Watch Connected" : "Waiting for Apple Watch...")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                    
                    // Bagian Kanan: Tombol Tap to Start & Panduan Singkat
                    VStack(spacing: 20) {
                        Button {
                            withAnimation(.spring()) {
                                isPlaying = true
                            }
                        } label: {
                            Text("TAP TO START")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .tracking(3)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color.orange)
                                        .shadow(color: .orange.opacity(0.5), radius: 12, x: 0, y: 4)
                                )
                                .scaleEffect(animateButton ? 1.04 : 0.96)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                }
                .padding(.vertical, 16)
            }
            .onAppear {
                // Mainkan musik latar belakang (BGM)
                SoundManager.shared.playBGM()
                
                // Paksa orientasi ke Landscape saat menu muncul
                setLandscapeOrientation()
                
                // Jalankan animasi pulsasi tombol
                withAnimation(
                    .easeInOut(duration: 0.9)
                    .repeatForever(autoreverses: true)
                ) {
                    animateButton = true
                }
            }
        }
    }
    
    // Helper untuk memaksa orientasi Landscape
    private func setLandscapeOrientation() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        // Kita infokan ke sistem untuk merotasi ke landscape
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
    }
}

#Preview {
    MainMenuView()
}
