import SwiftUI
import SwiftData

struct ReviewMomentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ReviewMomentViewModel()
    @State private var navigateToCalendar = false
    @State private var showingCreateMoment = false
    @State private var showingReflectMoment = false
    @State private var showingRecap = false
    @State private var reflectionToEdit: Reflection?
    @State private var savedReflectionForAnimation: Reflection?
    @AppStorage("shouldShowCreateMomentFromWidget") private var shouldShowCreateMomentFromWidget = false
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var dayOfWeekString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE,"
        return formatter.string(from: viewModel.selectedDate)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: viewModel.selectedDate)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: Header — Tanggal, Arsip, Profil
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dayOfWeekString)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Text(dateString)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: { navigateToCalendar = true }) {
                                Image(systemName: "archivebox")
                                    .font(.system(size: 24))
                                    .foregroundColor(.black)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)
                            
                            NavigationLink {
                                ParentProfileView()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "face.smiling.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // MARK: Ringkasan Mingguan
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ringkasan Mingguan")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            Button(action: { showingRecap = true }) {
                                HStack(spacing: 16) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.yellow)
                                        .frame(width: 110, height: 80)
                                        .overlay(
                                            Image(systemName: "note.text")
                                                .font(.largeTitle)
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text("Klik disini untuk\nisi refleksi\nmingguan")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(20)
                            }
                            .padding(.horizontal)
                        }
                        
                        // MARK: Refleksi Hari Ini
                        if !viewModel.moments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Refleksi Hari Ini")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                
                                if let reflection = viewModel.reflection {
                                    ReflectionCard(reflection: reflection, onEdit: {
                                        reflectionToEdit = reflection
                                    })
                                } else {
                                    VStack(spacing: 16) {
                                        Button(action: { showingReflectMoment = true }) {
                                            Image(systemName: "plus")
                                                .font(.title)
                                                .foregroundColor(Color.blue)
                                                .frame(width: 80, height: 80)
                                                .background(Color.blue.opacity(0.2))
                                                .clipShape(Circle())
                                        }
                                        
                                        VStack(spacing: 4) {
                                            Text("Belum ada refleksi hari ini")
                                                .font(.headline.weight(.semibold))
                                                .foregroundColor(.black)
                                            
                                            Text("Refleksi harianmu akan muncul di sini setelah kamu\nmulai mencatat momen")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.center)
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
                        
                        // MARK: Momen Hari Ini — grid / empty state
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Momen Hari Ini\(viewModel.moments.isEmpty ? "" : " (\(viewModel.moments.count))")")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            if viewModel.moments.isEmpty {
                                VStack(spacing: 16) {
                                    Button(action: { showingCreateMoment = true }) {
                                        Image(systemName: "plus")
                                            .font(.title)
                                            .foregroundColor(Color.blue)
                                            .frame(width: 80, height: 80)
                                            .background(Color.blue.opacity(0.2))
                                            .clipShape(Circle())
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("Belum ada momen hari ini")
                                            .font(.headline.weight(.semibold))
                                            .foregroundColor(.black)
                                        
                                        Text("Tambah satu momen untuk memulai harimu\ndengan Si Kecil")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 36)
                                .background(Color.white)
                                .cornerRadius(24)
                                .padding(.horizontal)
                            } else {
                                LazyVGrid(columns: gridColumns, spacing: 12) {
                                    ForEach(viewModel.moments) { moment in
                                        NavigationLink(destination: MomentDetailView(allDayMoments: viewModel.moments, initialMoment: moment, viewModel: viewModel)) {
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
                                            .aspectRatio(0.8, contentMode: .fit)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))

                // MARK: Overlay Pengingat Refleksi
                if viewModel.isShowingReflectionReminderOverlay {
                    reflectionReminderOverlay
                }

                if let reflection = savedReflectionForAnimation {
                    ReflectionSavedView(reflection: reflection, onClose: {
                        withAnimation { savedReflectionForAnimation = nil }
                    })
                    .transition(.opacity)
                }
            }
            // MARK: Lifecycle & Observasi
            .onAppear {
                viewModel.modelContext = modelContext
                viewModel.fetchData()
                showCreateMomentIfNeeded()
                viewModel.showReflectionReminderOverlayIfNeeded()
            }
            .onChange(of: shouldShowCreateMomentFromWidget) { _, _ in
                showCreateMomentIfNeeded()
            }
            .onChange(of: viewModel.reflection) { _, _ in
                viewModel.showReflectionReminderOverlayIfNeeded()
            }
            // MARK: Navigasi & Sheet
            .navigationDestination(isPresented: $navigateToCalendar) {
                CalendarHistoryView()
            }
            .sheet(isPresented: $showingCreateMoment, onDismiss: {
                viewModel.fetchData()
            }) {
                CreateMomentView()
            }
            .sheet(isPresented: $showingReflectMoment, onDismiss: {
                viewModel.fetchData()
            }) {
                ReflectMomentView(
                    modelContext: modelContext,
                    onClose: { showingReflectMoment = false },
                    onSaved: { reflection in
                        showingReflectMoment = false
                        showSavedAnimation(for: reflection)
                    }
                )
            }
            .sheet(item: $reflectionToEdit, onDismiss: {
                viewModel.fetchData()
            }) { reflection in
                ReflectMomentView(
                    modelContext: modelContext,
                    date: reflection.date,
                    editingReflection: reflection,
                    onClose: { reflectionToEdit = nil },
                    onSaved: { updated in
                        reflectionToEdit = nil
                        showSavedAnimation(for: updated)
                    }
                )
            }
        }
    }

    // tampilkan animasi setelah sheet selesai ditutup, agar confetti tampil penuh di atas ReviewMomentView
    private func showSavedAnimation(for reflection: Reflection) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            viewModel.fetchData()
            withAnimation(.easeIn(duration: 0.2)) {
                savedReflectionForAnimation = reflection
            }
            .sheet(isPresented: $showingRecap, onDismiss: {
                viewModel.fetchData()
            }) {
                RecapMomentView(modelContext: modelContext)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
    }

    // MARK: - Helpers
    private func showCreateMomentIfNeeded() {
        guard shouldShowCreateMomentFromWidget else { return }
        shouldShowCreateMomentFromWidget = false
        showingCreateMoment = true
    }

    // MARK: - Subviews
    private var reflectionReminderOverlay: some View {
        Color.black.opacity(0.2)
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing) {
                Image("Flexible")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .padding(.bottom, 22)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.dismissReflectionReminderOverlay()
            }
    }
}
