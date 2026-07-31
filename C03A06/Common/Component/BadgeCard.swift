//
//  BadgeCard.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//

import SwiftUI

struct BadgeCard: View {

    // MARK: - Properties

    let badge: BadgeType

    // Berapa minggu lencana ini pernah didapat. Nol berarti belum didapat.
    let timesEarned: Int

    // MARK: - Computed Properties

    private var isLocked: Bool { timesEarned <= 0 }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            Image(isLocked ? BadgeType.lockedImageName : badge.imageName)
                .resizable()
                // Tinggi dikunci, lebar mengikuti rasio asli artwork (~638x804).
                .scaledToFit()
                .frame(height: 99)
                .opacity(isLocked ? 0.5 : 1)
                .accessibilityHidden(true)

            Text(badge.title)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(isLocked ? .secondary : .primary)

            Text("\(timesEarned)")
                .font(.caption2.bold())
                // Angka selebar sama rata, jadi kapsul tidak bergoyang antar nilai.
                .monospacedDigit()
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(minWidth: 44)
                .background(Color(.systemGray6), in: .capsule)
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isLocked
            ? "\(badge.title), belum didapat"
            : "\(badge.title), didapat \(timesEarned) minggu"
        )
    }
}

// MARK: - Preview

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
        // 1 dan 12 harus menghasilkan kapsul selebar sama.
        BadgeCard(badge: .pemulaMomen, timesEarned: 1)
        BadgeCard(badge: .hadirPenuh, timesEarned: 12)
        // Belum didapat: pakai artwork kosong.
        BadgeCard(badge: .refleksiRutin, timesEarned: 0)
    }
    .padding()
    .background(Color(.systemGray6))
}
