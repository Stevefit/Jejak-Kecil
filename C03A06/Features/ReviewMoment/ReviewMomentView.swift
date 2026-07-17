import SwiftUI
import SwiftData

struct ReviewMomentView: View {
    @State private var viewModel: ReviewMomentViewModel
    
    init(modelContext: ModelContext? = nil) {
        _viewModel = State(wrappedValue: ReviewMomentViewModel(modelContext: modelContext))
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        ZStack {
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { viewModel.selectedDate },
                                    set: { viewModel.changeDate(to: $0) }
                                ),
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .accentColor(.blue)
                            .opacity(0.011)
                            .frame(width: 44, height: 44)
                            
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 4)
                                .allowsHitTesting(false)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Home")
                                .font(.system(size: 18, weight: .medium))
                            Text(dateFormatter.string(from: viewModel.selectedDate).uppercased())
                                .font(.system(size: 16, weight: .bold))
                                .italic()
                        }
                        .padding(.trailing, 44)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    Text("Halo Ayah Bunda")
                        .font(.system(size: 22, weight: .medium))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Momen Hari Ini")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.moments) { moment in
                                    NavigationLink(value: moment) {
                                        Group {
                                            if let uiImage = UIImage(data: moment.photo) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                            } else {
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .frame(width: 140, height: 180)
                                        .background(Color(.systemGray5))
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                                }
                                
                                Button(action: {}) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [5, 5]))
                                        .overlay(
                                            VStack(spacing: 8) {
                                                Image(systemName: "plus")
                                                    .font(.title2)
                                                if viewModel.moments.isEmpty {
                                                    Text("Tambah Momen")
                                                        .font(.caption)
                                                }
                                            }
                                            .foregroundColor(.black)
                                        )
                                        .frame(width: viewModel.moments.isEmpty ? 160 : 140, height: 180)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Refleksi Hari Ini
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Refleksi Hari Ini")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        if let reflection = viewModel.reflection, reflection.isCompleted {
                            HStack(spacing: 0) {
                                Group {
                                    if let moment = reflection.moment, let uiImage = UIImage(data: moment.photo) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                    } else {
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(width: 150, height: 220)
                                .background(Color(.systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(dateFormatter.string(from: viewModel.selectedDate))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    if let desc = reflection.moment?.shortDescription {
                                        Text(desc)
                                            .font(.system(size: 16, weight: .bold))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    if let feeling = reflection.answers.first(where: { $0.question.code == "Q4" })?.selectedChip {
                                        Text(feeling)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 6)
                                            .background(Color.yellow)
                                            .cornerRadius(20)
                                    }
                                    
                                    if let routine = reflection.answers.first(where: { $0.question.code == "Q6" })?.essayText {
                                        Text(routine)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if let initiative = reflection.answers.first(where: { $0.question.code == "Q1" })?.selectedChoice?.text {
                                        Text("\"\(initiative)\"")
                                            .font(.system(size: 12, weight: .medium))
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.leading, 16)
                                .padding(.trailing, 8)
                                
                                Spacer()
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        } else {
                            Button(action: {}) {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "square.and.pencil")
                                            .font(.title2)
                                        Text("Belum ada refleksi. Tulis sekarang?")
                                            .font(.subheadline)
                                    }
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 40)
                                    Spacer()
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Kilas Balik Minggu
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kilas Balik Minggu")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        VStack {
                            Button(action: {}) {
                                Text("Isi Recap")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 180, height: 48)
                                    .background(Color.blue)
                                    .cornerRadius(24)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                            .padding(.vertical, 32)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemBackground))
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.fetchDataForSelectedDate()
            }
            .navigationDestination(for: Moment.self) { moment in
                MomentDetailView(allDayMoments: viewModel.moments, initialMoment: moment)
            }
        }
    }
}

#Preview {
    ReviewMomentView()
}
