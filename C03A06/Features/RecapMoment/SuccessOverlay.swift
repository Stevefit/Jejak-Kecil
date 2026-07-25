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
    // Frame tombol Arsip (koordinat overlay) — area ini dibuat berlubang.
    var highlightRect: CGRect = .zero
    // "Lihat Ringkasan" (buka arsip/ringkasan).
    var onViewSummary: () -> Void = {}
    // "Nanti Saja" (tutup overlay).
    var onDismiss: () -> Void = {}

    var body: some View {
        ZStack {
            // MARK: Latar gelap transparan 70% + lubang di tombol Arsip
            // Tap area gelap = tutup overlay (biar tidak menyangkut menutupi layar).
            Color.black.opacity(0.7)
                .reverseMask {
                    Circle()
                        .frame(width: highlightRect.width, height: highlightRect.height)
                        .position(x: highlightRect.midX, y: highlightRect.midY)
                }
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }

            // MARK: Lubang tombol Arsip bisa ditap = langsung buka arsip
            Button(action: onViewSummary) {
                Circle().fill(.clear).contentShape(Circle())
            }
            .frame(width: highlightRect.width, height: highlightRect.height)
            .position(x: highlightRect.midX, y: highlightRect.midY)

            // MARK: Sorotan tombol arsip + panah (menyesuaikan posisi tombol di ReviewMomentView)
            archiveHighlight
          
            
            // MARK: Konten utama
            content
        }
    }
    
    // MARK: - Sorotan Tombol Arsip
    private var archiveHighlight: some View {
        VStack(alignment: .trailing, spacing: 4) {
            halfSizeImage("CurvedArrow")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, 20)
                .padding(.top, 116)
        }
    }
    
    // MARK: - Konten
    private var content: some View {
        VStack(spacing:0){
            Text("Yay, refleksi\nmingguanmu tersimpan!")
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.bottom, 20)
            
            halfSizeImage("RecapDone")
                .padding(.bottom, 15)
            
            
            
            Text("Ringkasan lengkapmu sudah bisa\ndilihat di arsip")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.bottom, 40)
            
            
            
            PrimaryButton(title: "Lihat Ringkasan", action: onViewSummary)
                .padding(.bottom, 16)
            
            
            Button("Nanti Saja", action: onDismiss)
                .font(.subheadline)
                .underline()
                .foregroundStyle(.white)
            
        }
        .padding(.horizontal, 40)
        .padding(.top,58)
    }
    
    // MARK: - Helper
    // Aset dari sketch sy downlaod x2 jadi pakai ini untuk samakan ukuran asli
    @ViewBuilder
    private func halfSizeImage(_ name: String) -> some View {
        if let ui = UIImage(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(width: ui.size.width / 2, height: ui.size.height / 2)
        }
    }
}

