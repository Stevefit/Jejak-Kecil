//
//  BadgeGridView.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//
import SwiftUI

struct BadgeGridView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(0..<4, id: \.self) { _ in
                BadgeCard()
            }
        }
    }
}


