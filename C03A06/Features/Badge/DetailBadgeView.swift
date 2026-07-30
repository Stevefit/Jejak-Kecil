//
//  DetailBadgeView.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 30/07/26.
//
//  Overlay detail lencana yang dibuka dari daftar lencana di profil.
//  Latar gelap transparan, kartu detail di tengah, tombol tutup di bawah.
//

import SwiftUI

struct DetailBadgeView: View {

    // MARK: - Properties

    let badge: BadgeType
    let timesEarned: Int
    let onClose: () -> Void

    // MARK: - State

    @State private var isVisible = false

    private let fade: Animation = .easeInOut(duration: 0.2)

    // MARK: - Layout

    private let closeButtonSize: CGFloat = 46

    // Jarak tombol tutup ke sisi bawah kartu.
    private let closeButtonGap: CGFloat = 28

    // MARK: - Body

    var body: some View {
        ZStack {
           
            Color.black.opacity(0.7)
                .contentShape(.rect)
                .onTapGesture(perform: close)

            DetailBadgeCard(badge: badge, timesEarned: timesEarned)
                .overlay(alignment: .bottom) {
                    closeButton
                        .offset(y: closeButtonSize + closeButtonGap)
                }
        }
        .ignoresSafeArea()
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(fade) { isVisible = true }
        }
    }

    // MARK: - Tutup

    // Fade dulu sampai habis, baru overlay-nya dilepas dari hierarki.
    private func close() {
        withAnimation(fade) {
            isVisible = false
        } completion: {
            onClose()
        }
    }

    private var closeButton: some View {
        Button(action: close) {
            Image(systemName: "xmark")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.black)
                .frame(width: closeButtonSize, height: closeButtonSize)
                .background(.white, in: .circle)
        }
    }
}

// MARK: - Preview

#Preview("Sudah didapat") {
    ZStack {
        Color(.systemGray6)
        DetailBadgeView(badge: .rumahSiKecil, timesEarned: 3, onClose: {})
    }
}

#Preview("Belum didapat") {
    ZStack {
        Color(.systemGray6)
        DetailBadgeView(badge: .semingguPenuh, timesEarned: 0, onClose: {})
    }
}
