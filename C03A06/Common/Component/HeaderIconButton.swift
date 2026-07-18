//
//  HeaderIconButton.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 17/07/26.
//

import SwiftUI

struct HeaderIconButton: View {
    let icon: String
    var backgroundColor: Color = Color(.systemGray6)
    var foregroundColor: Color = .primary
    var isEnabled: Bool = true
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isEnabled ? foregroundColor : .secondary)
                .frame(width: 32, height: 32)
                .background(Circle().fill(isEnabled ? backgroundColor : Color(.systemGray5)))
                .scaleEffect(isPressed ? 1.15 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0) //animation membesar kecil saat ditekan
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                        isPressed = false
                    }
                }
        )
    }
}
