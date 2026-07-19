//
//  MomentCard.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 18/07/26.
//


import SwiftUI

struct MomentCard: View {
    let moment: Moment

    var body: some View {
        Group {
            if let uiImage = UIImage(data: moment.photo) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color(.systemGray4)
                    Image(systemName: "photo")
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: 140, height: 180)
        .cornerRadius(16)
        .clipped()
    }
}
