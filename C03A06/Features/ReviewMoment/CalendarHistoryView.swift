//
//  CalendarHistoryView.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 17/07/26.
//


import SwiftUI

struct CalendarHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Juni, 2026")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 16) {
                    weeklyCard(title: "Minggu 1", range: "13-19 Juni 2026", count: 5, imageName: "person.2.fill")
                    weeklyCard(title: "Minggu 2", range: "20-26 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                    weeklyCard(title: "Minggu 3", range: "13-19 Juni 2026", count: 5, imageName: "person.2.fill")
                    weeklyCard(title: "Minggu 4", range: "20-26 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .navigationBarHidden(true)
    }
    
    private func weeklyCard(title: String, range: String, count: Int, imageName: String) -> some View {
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