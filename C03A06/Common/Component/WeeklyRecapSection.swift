//
//  WeeklyRecapSection.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 26/07/26.
//

import SwiftUI
import SwiftData

struct WeeklyRecapSection: View {
    let modelContext: ModelContext
    // Dipanggil setelah Recap berhasil disimpan (untuk memicu overlay sukses).
    var onRecapSaved: () -> Void = {}
    // Dipanggil saat sheet Recap ditutup (untuk refresh data).
    var onDismiss: () -> Void = {}

    @State private var showingRecap = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ringkasan Mingguan")
                .font(.headline.weight(.semibold))
                .foregroundColor(.black)

            Button(action: { showingRecap = true }) {
                HStack(spacing: 14) {
                    HalfSizeImage("CardRecap")
                        .padding(.leading, 23)

                    Text("Klik disini untuk\nisi refleksi\nmingguan")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: true, vertical: false)

                    Spacer()
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .sheet(isPresented: $showingRecap, onDismiss: onDismiss) {
                RecapMomentView(modelContext: modelContext, onSaved: onRecapSaved)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }.padding(.horizontal,20)
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    return WeeklyRecapSection(modelContext: container.mainContext)
        .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .modelContainer(container)
}
 
