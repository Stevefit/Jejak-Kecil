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
                HalfSizeImage("CardRecap")
                    .padding(.leading, 23)
                
                VStack(alignment: .leading, spacing: 8){
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .multilineTextAlignment(.leading)
                
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                .foregroundColor(.black)
                
                Spacer()
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
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
        title: "Oops! Tidak\nada ringkasan",
        subtitle: "Klik disini untuk isi\nrefleksi mingguan",
        modelContext: container.mainContext
    )
    .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .modelContainer(container)
}

