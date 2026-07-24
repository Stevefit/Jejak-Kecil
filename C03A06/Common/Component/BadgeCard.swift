//
//  BadgeCard.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//


//
//  BadgeCard.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//

import SwiftUI

struct BadgeCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image("badge")

            Text("Title")
                .font(.caption2)
                .bold()

            Text("10")
                .font(.caption2)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.gray)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}