//
//  NavigationHeaderBar.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 17/07/26.
//


//  leading & trailing button sama-sama pake HeaderIconButton, judul di tengah.

import SwiftUI

struct NavigationHeaderBar: View {

    let title: String

    let leadingIcon: String
    let onLeadingTap: () -> Void

    let trailingIcon: String
    var trailingColor: Color = Color(.systemGray6)
    var trailingForegroundColor: Color = .primary
    var isTrailingEnabled: Bool = true
    let onTrailingTap: () -> Void

    // MARK: progress bar
    var progressCurrent: Int = 0
    var progressTotal: Int = 0
    var progressActiveColor: Color = .primary
    var progressInactiveColor: Color = Color(.systemGray5)

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HeaderIconButton(
                    icon: leadingIcon,
                    backgroundColor: Color(.systemGray6),
                    foregroundColor: .primary,
                    action: onLeadingTap
                )

                Spacer()

                VStack(spacing: 5) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))

                    if progressTotal > 0 {
                        Text("\(progressCurrent) dari \(progressTotal)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                HeaderIconButton(
                    icon: trailingIcon,
                    backgroundColor: trailingColor,
                    foregroundColor: trailingForegroundColor,
                    isEnabled: isTrailingEnabled,
                    action: onTrailingTap
                )
            }

            if progressTotal > 0 {
                progressBar
            }
        }
    }

    // MARK: progress bar u/ satu kapsul per langkah
    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(progressTotal, 0), id: \.self) { index in
                Capsule()
                    .fill(index < progressCurrent ? progressActiveColor : progressInactiveColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 5)
            }
        }
    }
}
