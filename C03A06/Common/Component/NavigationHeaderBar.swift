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

    // MARK: progress dots
    var progressCurrent: Int = 0
    var progressTotal: Int = 0
    var progressActiveColor: Color = .blue
    var progressInactiveColor: Color = Color(.systemGray4)

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HeaderIconButton(
                    icon: leadingIcon,
                    backgroundColor: Color(.systemGray6),
                    foregroundColor: .primary,
                    action: onLeadingTap
                )

                Spacer()

                Text(title)
                    .font(.subheadline.weight(.semibold))

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
                HStack(spacing: 4) {
                    ForEach(0..<progressTotal, id: \.self) { index in
                        Circle()
                            .fill(index == progressCurrent - 1 ? progressActiveColor : progressInactiveColor)
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
    }
}
