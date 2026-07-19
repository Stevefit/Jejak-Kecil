//
//  WeeklyCard.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 18/07/26.
//


import SwiftUI

struct WeeklyCard: View {
    let title: String
    let range: String
    let count: Int
    let imageName: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Color(.systemGray4)
                Image(systemName: imageName)
                    .font(.title)
                    .foregroundColor(.white)
            }
            .frame(width: 110, height: 110)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text(range)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(count) momen tercatat")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 4, x: 0, y: 2)
    }
}