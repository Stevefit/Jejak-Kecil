import SwiftUI
import SwiftData

struct MomentDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    
    var allDayMoments: [Moment]
    @State private var currentMoment: Moment
    var viewModel: ReviewMomentViewModel
    
    init(allDayMoments: [Moment], initialMoment: Moment, viewModel: ReviewMomentViewModel) {
        self.allDayMoments = allDayMoments
        self._currentMoment = State(initialValue: initialMoment)
        self.viewModel = viewModel
    }

    private var currentIndex: Int {
        allDayMoments.firstIndex(where: { $0.id == currentMoment.id }) ?? 0
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: currentMoment.timestamp)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .aspectRatio(3/4, contentMode: .fit)
                        .overlay {
                            if let uiImage = UIImage(data: currentMoment.photo) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                ZStack {
                                    Color(.systemGray5)
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .clipped()

                    HStack {
                        if currentIndex > 0 {
                            Button(action: { currentMoment = allDayMoments[currentIndex - 1] }) {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(12)
                                    .background(Color.white)
                                    .clipShape(Circle())
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
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Text(dateText)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text(currentMoment.category.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.yellow.opacity(0.4))
                            .clipShape(Capsule())
                    }

                    Text(currentMoment.shortDescription)
                        .font(.body)
                        .foregroundColor(.black)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 19)
        }
        .appBackground()
        .navigationTitle("Detail Momen")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $isEditing, onDismiss: {
            if let updated = viewModel.moments.first(where: { $0.id == currentMoment.id }) {
                currentMoment = updated
            }
        }) {
            EditMomentView(
                moment: currentMoment,
                isPresented: $isEditing,
                viewModel: viewModel,
                onDelete: {
                    dismiss()
                }
            )
        }
    }
}
