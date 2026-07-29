//
//  AppBackground.swift
//  C03A06
//
//  Gradasi latar untuk layar utama (bukan modal).
//

import SwiftUI

extension View {

    // Pakai di root layar non-modal. Sheet punya latar sendiri, jadi tidak perlu
    // dikecualikan secara manual.
    func appBackground() -> some View {
        scrollContentBackground(.hidden)
            .background {
                AppBackground()
            }
    }
}

// Warna dasar rata + pita gradasi bertinggi tetap di atas.
//
// Tingginya sengaja dikunci dalam poin, bukan persentase. Kalau pakai
// LinearGradient setinggi layar, `location` ikut tinggi container — jadi bentuknya
// berubah-ubah antara preview, ScrollView pendek, dan ScrollView panjang.
private struct AppBackground: View {

    // Naikkan kalau mau warnanya turun lebih jauh, turunkan kalau mau lebih ketat
    // di sekitar Dynamic Island.
    private let bandHeight: CGFloat = 260

    var body: some View {
        Color(.systemGray6)
            .overlay(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: .gradientTop, location: 0.00),
                        .init(color: .gradientBottom, location: 0.4),
                        // #EBEDF9 — jembatan menuju warna dasar.
                        .init(color: Color(red: 0.922, green: 0.929, blue: 0.976), location: 0.60),
                        // Stop terakhir wajib sama dengan warna dasar, supaya
                        // ujung pita tidak kelihatan sebagai garis.
                        .init(color: Color(.systemGray6), location: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: bandHeight)
            }
            .ignoresSafeArea()
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Momen Hari Ini")
                .font(.headline.weight(.semibold))

            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .frame(height: 340)

            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .frame(height: 340)
        }
        .padding(20)
    }
    .appBackground()
}
