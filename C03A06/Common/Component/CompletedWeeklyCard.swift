//
//  CompletedWeeklyCard.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 26/07/26.
//

import SwiftUI
import SwiftData

struct CompletedWeeklyCard: View {
    let recap: Recap
    let weekTitle: String
    let dateRange: String
    let totalReflections: Int
    
    // Dipanggil saat card ditekan (misal untuk navigasi ke detail arsip)
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                // MARK: Foto Sampul (Menempel di kiri penuh)
                if let photoData = recap.highlightedReflection?.moment?.photo, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipped()
                } else {
                    // Fallback warna abu-abu jika foto tidak ditemukan
                    Color(.systemGray4)
                        .frame(width: 140, height: 140)
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                }
                
                // MARK: Teks Informasi
                VStack(alignment: .leading, spacing: 6) {
                    Text(weekTitle)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(dateRange)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 6) {
                        Text("🗒️")
                            .font(.headline)
                        
                        Text("\(totalReflections) refleksi tercatat")
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.leading, 16)
                .padding(.trailing, 8)
                
                Spacer()
            }
            .frame(height: 140)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    // Buat data gambar dummy menggunakan warna solid (misal hijau)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 140, height: 140))
    let colorImage = renderer.image { context in
        UIColor.systemGreen.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 140, height: 140))
    }
    let dummyImageData = colorImage.jpegData(compressionQuality: 0.8) ?? Data()
    
    let dummyMoment = Moment(photo: dummyImageData, timestamp: Date(), shortDescription: "Momen seru", category: .bermainBersama)
    let dummyReflection = Reflection(date: Date(), moment: dummyMoment, isCompleted: true)
    let dummyRecap = Recap(weekStart: Date(), highlightedReflection: dummyReflection, isCompleted: true)
    
    return CompletedWeeklyCard(
        recap: dummyRecap,
        weekTitle: "Ringkasan Minggu 1",
        dateRange: "13-19 Juni 2026",
        totalReflections: 5
    )
    .padding(.vertical)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemGray6))
    .modelContainer(container)
}
