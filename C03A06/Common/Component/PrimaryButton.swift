//
//  PrimaryButton.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 21/07/26.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 35)
        }
        .font(.headline)
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(.blue)
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Selanjutnya") {}
        PrimaryButton(title: "Selanjutnya", isEnabled: false) {}
    }
    .padding()
}
