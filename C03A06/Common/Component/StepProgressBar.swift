//
//  StepProgressBar.swift
//  C03A06
//

import SwiftUI

/// Segmented progress bar — satu kapsul per langkah, terisi sampai `current`.
struct StepProgressBar: View {
    let current: Int
    let total: Int
    var activeColor: Color = .primary
    var inactiveColor: Color = Color(.systemGray5)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(total, 0), id: \.self) { index in
                Capsule()
                    .fill(index == current - 1 ? activeColor : inactiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 5)
            }
        }

    }
}

#Preview {
    VStack(spacing: 20) {
        StepProgressBar(current: 1, total: 2)
        StepProgressBar(current: 3, total: 5)
    }
    .padding()
}
