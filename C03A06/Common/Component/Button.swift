//
//  Button.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
//  Tombol reusable berbasis komponen native Apple.
//

import SwiftUI

// Tombol utama full-width (native bordered prominent), mis. "Selanjutnya".
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!isEnabled)
    }
}

// Tombol sekunder berupa teks biasa (native), mis. "Kembali".
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
    }
}
