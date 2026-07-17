import SwiftUI
import SwiftData

struct MomentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    
    var allDayMoments: [Moment]
    @State private var currentMoment: Moment
    
    init(allDayMoments: [Moment], initialMoment: Moment) {
        self.allDayMoments = allDayMoments
        self._currentMoment = State(initialValue: initialMoment)
    }

    private var currentIndex: Int {
        allDayMoments.firstIndex(where: { $0.id == currentMoment.id }) ?? 0
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: currentMoment.timestamp).uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Carousel Image Block
            ZStack {
                Group {
                    if let uiImage = UIImage(data: currentMoment.photo) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 400)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipped()

                // Overlay Arrow Indicators
                HStack {
                    if currentIndex > 0 {
                        Button(action: { currentMoment = allDayMoments[currentIndex - 1] }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        }
                    }
                    
                    Spacer()
                    
                    if currentIndex < allDayMoments.count - 1 {
                        Button(action: { currentMoment = allDayMoments[currentIndex + 1] }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 4)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Text Content Box (Fixed Alignment)
            VStack(alignment: .leading, spacing: 12) {
                Text(dateText)
                    .font(.system(size: 16, weight: .bold))
                    .italic()

                Text(currentMoment.shortDescription ?? "")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(24) // This properly indents the text without pushing it off-screen
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemGray6).ignoresSafeArea())
        
        // Native Navigation Bar
        .navigationTitle("Detail Momen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 4)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 4)
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditMomentView(moment: currentMoment, isPresented: $isEditing)
        }
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let sampleData = UIImage(systemName: "photo")!.jpegData(compressionQuality: 0.8)!
    let sampleMoment = Moment(
        photo: sampleData,
        timestamp: Date(),
        shortDescription: "Main bikin rumah-rumahan sama Lili."
    )
    container.mainContext.insert(sampleMoment)

    return NavigationStack {
        MomentDetailView(allDayMoments: [sampleMoment], initialMoment: sampleMoment)
    }
    .modelContainer(container)
}
