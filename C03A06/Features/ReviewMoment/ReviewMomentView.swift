import SwiftUI
import SwiftData

struct ReviewMomentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var parents: [Parent]
    @State private var viewModel = ReviewMomentViewModel()
    @State private var navigateToCalendar = false
    @State private var showingCreateMoment = false
    @State private var showingReflectMoment = false
    @State private var reflectionToEdit: Reflection?
    @State private var savedReflectionForAnimation: Reflection?
    @State private var showSuccessOverlay = false
    @State private var calendarInitialTab = 1
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

    private var profileImageName: String {
        parents.first?.parentRole == .ibu ? "Mother" : "Father"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: Ringkasan Mingguan — hanya hari Minggu & belum diisi
                        if viewModel.shouldShowWeeklyRecap {
                            WeeklyRecapSection(
                                modelContext: modelContext,
                                onRecapSaved: { showRecapSuccessOverlay() },
                                onDismiss: { viewModel.fetchData() }
                            )
                        }
                        
                        // MARK: Refleksi Hari Ini
                        if !viewModel.moments.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Refleksi Hari Ini")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.black)

                                if let reflection = viewModel.reflection {
                                    ReflectionCard(reflection: reflection, onEdit: {
                                        reflectionToEdit = reflection
                                    })
                                    // cancel ReflectionCard's baked-in .padding(.horizontal)
                                    // supaya padding kartu juga 20 sejajar 
                                    .padding(.horizontal, -16)
                                } else {
                                    Button(action: { showingReflectMoment = true }) {
                                        VStack(spacing: 16) {
                                            Image("AddReflection")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 118, height: 131)
                                            
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
                                        .padding(.vertical, 28)
                                        .background(Color.white)
                                        .cornerRadius(24)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // MARK: Momen Hari Ini — grid / empty state
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Momen Hari Ini\(viewModel.moments.isEmpty ? "" : " (\(viewModel.moments.count))")")
                                .font(.headline.weight(.semibold))
                                .foregroundColor(.black)

                            if viewModel.moments.isEmpty {
                                Button(action: { showingCreateMoment = true }) {
                                    VStack(spacing: 16) {
                                        Image("AddMoment")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 123, height: 136)
                                        
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
                                    .padding(.vertical, 28)
                                    .background(Color.white)
                                    .cornerRadius(24)
                                }
                                .buttonStyle(.plain)
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
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical)
                }
                .appBackground()

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
            // MARK: Navigation Title & Toolbar Setup

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dayOfWeekString)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        Text(dateString)
                            .font(.subheadline.weight(.regular))
                            .foregroundColor(.primary)
                    }
                    .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)
                // Archive Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Arsip", systemImage: "archivebox") {
                        calendarInitialTab = 1
                        navigateToCalendar = true
                    }
                    .buttonStyle(.plain)
                    .anchorPreference(key: ArchiveAnchorKey.self, value: .bounds) { $0 }
                }

                // Profile Button
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ParentProfileView()) {
                        Image(profileImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 38,height: 65)
                            .offset(y: 10)
                            .clipShape(Circle())
                            .frame(width: 24, height: 24)
                            .accessibilityLabel("Profil")
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.white)
                }
            }
            
            // MARK: Overlay Success Recap
            .overlayPreferenceValue(ArchiveAnchorKey.self) { anchor in
                if showSuccessOverlay, let anchor {
                    GeometryReader { proxy in
                        SuccessOverlay(
                            highlightRect: proxy[anchor],
                            onPrimaryAction: {
                                showSuccessOverlay = false
                                calendarInitialTab = 0
                                navigateToCalendar = true
                            },
                            onSecondaryAction: { showSuccessOverlay = false }
                        )
                    }
                    .ignoresSafeArea()
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
                CalendarHistoryView(initialTab: calendarInitialTab)
            }
            .sheet(isPresented: $showingCreateMoment, onDismiss: {
                viewModel.fetchData()
            }) {
                CreateMomentView(date: viewModel.selectedDate)
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

    private func showSavedAnimation(for reflection: Reflection) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            viewModel.fetchData()
            withAnimation(.easeIn(duration: 0.2)) {
                savedReflectionForAnimation = reflection
            }
        }
    }
    
    private func showRecapSuccessOverlay() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            withAnimation(.easeIn(duration: 0.2)) {
                showSuccessOverlay = true
            }
        }
    }
    
    private func showCreateMomentIfNeeded() {
        guard shouldShowCreateMomentFromWidget else { return }
        shouldShowCreateMomentFromWidget = false
        showingCreateMoment = true
    }

    private var reflectionReminderOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack {
                Spacer()

                HStack {
                    Image("ReflectionFlexible")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 247)

                    Spacer()
                }
                .padding(.leading, 23)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.dismissReflectionReminderOverlay()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Reflection.self, configurations: config)
    
    return ReviewMomentView()
        .modelContainer(container)
}
