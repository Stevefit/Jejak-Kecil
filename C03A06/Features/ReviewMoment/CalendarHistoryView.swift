import SwiftUI

struct CalendarHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    WeeklyCard(title: "Minggu 1", range: "13-19 Juni 2026", count: 5, imageName: "person.2.fill")
                    WeeklyCard(title: "Minggu 2", range: "20-26 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                    WeeklyCard(title: "Minggu 3", range: "13-19 Juni 2026", count: 5, imageName: "person.2.fill")
                    WeeklyCard(title: "Minggu 4", range: "20-26 Juni 2026", count: 7, imageName: "photo.on.rectangle.angled")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Menu {
                } label: {
                    HStack(spacing: 4) {
                        Text("Juni, 2026")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
