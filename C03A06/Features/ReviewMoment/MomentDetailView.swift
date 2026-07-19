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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    if let uiImage = UIImage(data: currentMoment.photo) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
                            .clipped()
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(width: geometry.size.width, height: geometry.size.height * 0.55)
                            .background(Color(.systemGray5))
                    }

                    HStack {
                        if currentIndex > 0 {
                            Button(action: { currentMoment = allDayMoments[currentIndex - 1] }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            }
                        }
                        
                        Spacer()
                        
                        if currentIndex < allDayMoments.count - 1 {
                            Button(action: { currentMoment = allDayMoments[currentIndex + 1] }) {
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(dateText)
                        .font(.body)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundColor(.black)

                    Text(currentMoment.shortDescription ?? "")
                        .font(.body)
                        .foregroundColor(.black)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Detail Momen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditMomentView(moment: currentMoment, isPresented: $isEditing)
        }
    }
}
