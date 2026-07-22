//
//  TextLinkButton.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 21/07/26.
//

import SwiftUI

/// Underlined text-link style button for secondary actions (e.g. "Kembali").
struct TextLinkButton: View {
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

#Preview {
    TextLinkButton(title: "Kembali") {}
}
