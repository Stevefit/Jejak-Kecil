//
//  BadgeGridView.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//
import SwiftUI

struct BadgeGridView: View {

    // MARK: - Properties

    // Berapa minggu tiap lencana pernah didapat. Yang tidak ada di sini
    // berarti belum pernah didapat dan tampil dalam versi kosong.
    let counts: [BadgeType: Int]

    // Dipanggil saat satu kartu ditap, untuk membuka detailnya.
    let onSelect: (BadgeType) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    // MARK: - Computed Properties

    // Yang sudah didapat naik ke atas, sisanya menyusul. Dipisah lewat dua filter
    // (bukan sorted) supaya urutan katalog di dalam tiap kelompok tetap terjaga —
    // sort di Swift tidak dijamin stabil.
    private var orderedBadges: [BadgeType] {
        let isEarned: (BadgeType) -> Bool = { (counts[$0] ?? 0) > 0 }
        return BadgeType.allCases.filter(isEarned) + BadgeType.allCases.filter { !isEarned($0) }
    }

    // MARK: - Body

    var body: some View {
        // Ketujuh lencana selalu tampil, supaya user tahu apa yang bisa dikejar.
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(orderedBadges, id: \.self) { badge in
                Button {
                    onSelect(badge)
                } label: {
                    BadgeCard(badge: badge, timesEarned: counts[badge] ?? 0)
                }
                // Kartunya sudah punya gaya sendiri, jadi tombol tidak ikut mewarnai.
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        // pemulaMomen ada di urutan kelima katalog, tapi harus naik ke baris atas.
        BadgeGridView(counts: [.hadirPenuh: 1, .pemulaMomen: 12], onSelect: { _ in })
            .padding()
    }
    .background(Color(.systemGray6))
}
