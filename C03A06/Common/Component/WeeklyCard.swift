//
//  WeeklyRecapSection.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 26/07/26.
//

import SwiftUI
import SwiftData

struct WeeklyCard: View {
    let title: String
    var subtitle: String? = nil
    // Rentang tanggal minggu tersebut. nil = tidak ditampilkan.
    var dateRange: String? = nil
    // Versi arsip pakai ilustrasi yang lebih kecil.
    var imageName: String = "CardRecap"
    var date: Date = .now

    let modelContext: ModelContext
    // Dipanggil setelah Recap berhasil disimpan (untuk memicu overlay sukses).
    var onRecapSaved: () -> Void = {}
    // Dipanggil saat sheet Recap ditutup (untuk refresh data).
    var onDismiss: () -> Void = {}
    
    @State private var showingRecap = false
    
    var body: some View {
        Button(action: { showingRecap = true }) {
            HStack(spacing: 13) {
                HalfSizeImage(imageName)
                    .padding(.leading, 23)

                VStack(alignment: .leading, spacing: 4){
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .multilineTextAlignment(.leading)
                        // Cuma \n di title yang boleh memutus baris, bukan wrap otomatis.
                        .fixedSize(horizontal: true, vertical: false)

                    if let dateRange {
                        Text(dateRange)
                            .font(.caption.weight(.medium))
                            .padding(.bottom, 6)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.vertical, 12)
                .foregroundColor(.black)
                
                Spacer()
            }
            // Disamakan dengan CompletedWeeklyCard supaya semua kartu di arsip
            // mingguan setinggi 140, apa pun ukuran ilustrasinya.
            .frame(height: 140)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
//        .padding(.horizontal, 20)
        .sheet(isPresented: $showingRecap, onDismiss: onDismiss) {
            RecapMomentView(modelContext: modelContext, date: date, onSaved: onRecapSaved)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    return WeeklyCard(
        title: "Klik disini untuk\nisi refleksi\nmingguan",
        modelContext: container.mainContext
    )
    .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .modelContainer(container)
}

