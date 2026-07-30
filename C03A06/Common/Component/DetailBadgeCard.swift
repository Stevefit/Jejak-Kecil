//
//  DetailBadgeCard.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 30/07/26.
//
//

import SwiftUI

struct DetailBadgeCard: View {

    // MARK: - Properties

    let badge: BadgeType
    let timesEarned: Int

    // MARK: - Computed Properties

    private var isLocked: Bool { timesEarned <= 0 }
    private var detail: String {
        isLocked
        ? "Oops! Kamu belum mendapatkan lencana ini."
        : badge.badgeDescription
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            Image(isLocked ? BadgeType.lockedImageName : badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 176, height: 224)

            VStack(spacing: 8) {
                Text(badge.title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .lineLimit(3, reservesSpace: true)
            }
            .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(width: 288, height: 389)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
      
        DetailBadgeCard(badge: .rumahSiKecil, timesEarned: 3)
        DetailBadgeCard(badge: .semingguPenuh, timesEarned: 0)
    }
    .padding(24)
    .background(Color(.systemGray6))
}
