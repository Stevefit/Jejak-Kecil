//
//  SelectableMomentCard.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 16/07/26.
//

import SwiftUI

struct SelectableMomentCard: View {

    let moment: Moment
    var isSelected: Bool = false

    var body: some View {

        ZStack {

            if let uiImage = UIImage(data: moment.photo) {
                Color.clear
                    .overlay {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    }
            } else {
                Rectangle()
                    .fill(.gray.opacity(0.2))
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isSelected ? 1.0 : 0.5)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    isSelected ? .blue : .clear,
                    lineWidth: 3
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
