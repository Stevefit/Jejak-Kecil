import SwiftUI

struct CalendarHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: Int = 0
    @State private var selectedDate: Date = Date()
    @State private var showingDatePicker = false

    private var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM, yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("", selection: $selectedTab) {
                Text("Mingguan").tag(0)
                Text("Harian").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            DatePickerLabel(title: formattedMonthYear) {
                showingDatePicker = true
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        WeeklyCard(title: "Ringkasan Minggu 1", range: "13-19 Juni 2026", count: 5, imageName: "photo.on.rectangle.angled")
                        WeeklyCard(title: "Ringkasan Minggu 2", range: "20-26 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                        WeeklyCard(title: "Ringkasan Minggu 3", range: "13-19 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                        WeeklyCard(title: "Ringkasan Minggu 4", range: "20-26 Juni 2026", count: 6, imageName: "photo.on.rectangle.angled")
                        WeeklyCard(title: "Ringkasan Minggu 4", range: "20-26 Juni 2026", count: 1, imageName: "photo.on.rectangle.angled")
                    } else {
                        WeeklyCard(title: "Hari Ini", range: "31 Juli 2026", count: 3, imageName: "photo.on.rectangle.angled")
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .navigationTitle("Arsip")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            NavigationStack {
                MonthYearPickerView(selectedDate: $selectedDate)
                    .navigationTitle("Pilih Bulan & Tahun")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Selesai") {
                                showingDatePicker = false
                            }
                        }
                    }
            }
            .presentationDetents([.fraction(0.35), .medium])
        }
    }
}

private struct DatePickerLabel: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}
