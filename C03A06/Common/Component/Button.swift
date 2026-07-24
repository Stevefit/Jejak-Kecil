//
//  Button.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
//  Tombol reusable berbasis komponen native Apple.
//

import SwiftUI

//MARK: tombol utama, contoh: "Selanjutnya"
struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal)
        }
        .font(.headline)
        .buttonStyle(.glassProminent)
        .controlSize(.large)
        .disabled(!isEnabled)
    }
}

//MARK:  tombol sekunder (teks biasa), contoh: "Kembali"
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .underline()
        }
        .foregroundStyle(.secondary)
    }
}

//MARK:  tombol close (X) untuk toolbar
struct CloseButton: View {
    var icon: String = "xmark"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
    }
}

//MARK:  tombol save
struct SaveButton: View {
    var icon: String = "checkmark"
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
        .buttonStyle(.glassProminent)
        .disabled(!isEnabled)
    }
}

#Preview{
    PrimaryButton(title:"Selanjutnya"){}
    PrimaryButton(title:"Selanjutnya", isEnabled: false){}
    PrimaryButton(title:"Simpan Perubahan"){}
    SecondaryButton(title: "Kembali"){}
    SaveButton(){}
}
