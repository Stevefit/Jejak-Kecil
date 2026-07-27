//
//  SuccessOverlay.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 24/07/26.
//
//  Overlay sukses setelah refleksi mingguan tersimpan.
//  Latar gelap transparan, menyorot tombol arsip, dan mengarahkan
//  panah ke tombol tersebut.
//

import SwiftUI

struct SuccessOverlay: View {
    // MARK: - Konfigurasi Konten
    var title: String = "Yay, refleksi\nmingguanmu tersimpan!"
    var subtitle: String = "Ringkasan lengkapmu sudah bisa\ndilihat di arsip"
    var imageName: String = "RecapDone"
    var primaryButtonTitle: String = "Lihat Ringkasan"
    var secondaryButtonTitle: String = "Nanti Saja"

    // Frame tombol (misal tombol Arsip) yang akan disorot. Jika nil, latar belakang penuh tanpa sorotan.
    var highlightRect: CGRect? = nil
    
    // Aksi tombol
    var onPrimaryAction: () -> Void = {}
    var onSecondaryAction: () -> Void = {}

    var body: some View {
        ZStack {
            // MARK: Latar gelap transparan 70%
            // Tap area gelap = tutup overlay (biar tidak menyangkut menutupi layar).
            Group {
                if let rect = highlightRect {
                    Color.black.opacity(0.7)
                        .reverseMask {
                            Circle()
                                .frame(width: rect.width, height: rect.height)
                                .position(x: rect.midX, y: rect.midY)
                        }
                } else {
                    Color.black.opacity(0.7)
                }
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture { onSecondaryAction() }

            // MARK: Lubang sorotan bisa ditap
            if let rect = highlightRect {
                Button(action: onPrimaryAction) {
                    Circle().fill(.clear).contentShape(Circle())
                }
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)
                
                // MARK: Panah sorotan (hanya muncul jika ada highlightRect)
                archiveHighlight
            }
            
            // MARK: Konten utama
            content
        }
    }
    
    // MARK: - Sorotan Tombol Arsip
    private var archiveHighlight: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HalfSizeImage("CurvedArrow")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 20)
                .padding(.top, 116)
        }
    }
    
    // MARK: - Konten
    private var content: some View {
        VStack(spacing:0){
            Text(title)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.bottom, 20)
            
            HalfSizeImage(imageName)
                .padding(.bottom, 15)
            
            Text(subtitle)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.bottom, 40)
            
            PrimaryButton(title: primaryButtonTitle, action: onPrimaryAction)
                .padding(.bottom, 16)
            
            Button(secondaryButtonTitle, action: onSecondaryAction)
                .font(.subheadline)
                .underline()
                .foregroundStyle(.white)
            
        }
        .padding(.horizontal, 40)
        .padding(.top, 58)
    }
}

