import SwiftUI
import SwiftData

struct ReviewMomentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ReviewMomentViewModel()
    @State private var navigateToCalendar = false
    @State private var showingCreateMoment = false
    @State private var showingReflectMoment = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            ZStack {
                                Color.orange.opacity(0.3)
                                Image(systemName: "face.smiling.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                            }
                            .frame(width: 54, height: 54)
                            .clipShape(Circle())
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Halo,")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("Amanda Agustine")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: { navigateToCalendar = true }) {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Momen Hari Ini")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(viewModel.moments) { moment in
                                    NavigationLink(destination: MomentDetailView(allDayMoments: viewModel.moments, initialMoment: moment)) {
                                        MomentCard(moment: moment)
                                    }
                                }
                                
                                Button(action: { showingCreateMoment = true }) {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.systemGray3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .overlay(
                                            Image(systemName: "plus")
                                                .font(.title2)
                                                .foregroundColor(.black)
                                        )
                                        .frame(width: 140, height: 180)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Refleksi Hari Ini")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        if let reflection = viewModel.reflection {
                            ReflectionCard(reflection: reflection)
                        } else {
                            VStack(spacing: 16) {
                                Button(action: {showingReflectMoment = true}) {
                                    Image(systemName: "plus")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .frame(width: 64, height: 64)
                                        .background(Color.blue.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                
                                VStack(spacing: 6) {
                                    Text("Belum ada refleksi hari ini")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    
                                    Text("Refleksi harianmu akan muncul di sini setelah kamu mulai mencatat momen")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 32)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 36)
                            .background(Color.white)
                            .cornerRadius(24)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.modelContext = modelContext
                viewModel.fetchData()
            }
            .navigationDestination(isPresented: $navigateToCalendar) {
                CalendarHistoryView()
            }
            .sheet(isPresented: $showingCreateMoment, onDismiss: {
                viewModel.fetchData()
            }) {
                CreateMomentView()
            }
            .sheet(isPresented: $showingReflectMoment, onDismiss: {
                viewModel.fetchData(in: modelContext)
            }) {
                ReflectMomentView(
                    modelContext: modelContext,
                    onClose: { showingReflectMoment = false }
                )
            }
        }
    }
}

#Preview {
    ReviewMomentView()
}
