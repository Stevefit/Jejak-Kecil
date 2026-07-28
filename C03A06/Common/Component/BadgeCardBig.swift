//
//  BadgeCardBig.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//
import SwiftUI

struct BadgeCardBig: View {

    // MARK: - Properties

    let badge: BadgeType

    // MARK: - Body

    var body: some View {
        HStack(spacing: 20) {
            Image(badge.imageName)
                .resizable()
                // Artwork-nya potret (~638x804). scaledToFit menjaga rasionya
                // supaya gambar tidak melar mengisi frame.
                .scaledToFit()
                .frame(width: 99, height: 125)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(badge.title)
                    .font(.headline.weight(.semibold))
                Text(badge.badgeDescription)
                    .font(.caption)
            }
            // Kolom teks mengisi sisa lebar, jadi kalimat pendek dan panjang
            // membungkus di lebar yang sama.
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        // Melebar penuh sebelum background dipasang, supaya kartu putihnya
        // seragam dan tidak menyusut mengikuti panjang kalimat.
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 16))
        // Satu elemen VoiceOver per lencana, bukan dua potongan terpisah.
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 8) {
            // Deskripsi terpendek dan terpanjang, untuk memastikan lebarnya sama.
            BadgeCardBig(badge: .pemulaMomen)
            BadgeCardBig(badge: .hadirPenuh)
            BadgeCardBig(badge: .semingguPenuh)
        }
        .padding(.horizontal, 16)
    }
    .frame(maxWidth: .infinity)
    .background(Color(.systemGray6))
}
