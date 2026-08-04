import SwiftUI
import SwiftData
import UIKit

struct NativeSegmentedPicker: UIViewRepresentable {
    @Binding var selection: Int
    let items: [String]

    func makeUIView(context: Context) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = selection
        segmentedControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.valueChanged(_:)),
            for: .valueChanged
        )
        return segmentedControl
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selection
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: NativeSegmentedPicker

        init(_ parent: NativeSegmentedPicker) {
            self.parent = parent
        }

        @objc func valueChanged(_ sender: UISegmentedControl) {
            parent.selection = sender.selectedSegmentIndex
        }
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? uiView.intrinsicContentSize.width, height: 48)
    }
}

struct CalendarHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = CalendarHistoryViewModel()
    @State private var savedReflectionForAnimation: Reflection?
    @State private var reflectionToEdit: Reflection?
    
    private var calendar: Calendar { Calendar.current }
    
    init(initialTab: Int = 1) {
        _viewModel = State(initialValue: CalendarHistoryViewModel(initialTab: initialTab))
    }
    
    @State private var showSuccessOverlay = false
    @State private var newlySavedRecap: Recap? = nil
    @State private var recapToNavigate: Recap? = nil
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                NativeSegmentedPicker(selection: $viewModel.selectedTab, items: ["Mingguan", "Harian"])
                    .frame(height: 48)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                
                DatePickerLabel(title: viewModel.formattedMonthYear) {
                    viewModel.showingDatePicker = true
                }
                // Sejajar dengan isi ScrollView di bawahnya, tetap 20 dari tepi
                // layar apa pun panjang nama bulannya.
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.selectedTab == 0 {
                            weeklySection
                        } else {
                            dailySection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .navigationTitle("Arsip")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(showSuccessOverlay ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
            .onChange(of: viewModel.selectedDate) {
                viewModel.fetchDataForMonth()
            }
            .sheet(isPresented: $viewModel.showingDatePicker) {
                NavigationStack {
                    MonthYearPickerView(selectedDate: $viewModel.selectedDate)
                        .navigationTitle("Pilih Bulan & Tahun")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Selesai") {
                                    viewModel.showingDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.fraction(0.35), .medium])
            }
            .sheet(isPresented: $viewModel.showingCreateMoment, onDismiss: {
                viewModel.fetchDataForMonth()
            }) {
                CreateMomentView(date: viewModel.selectedDate)
            }
            .sheet(isPresented: $viewModel.showingReflectMoment, onDismiss: {
                viewModel.fetchDataForMonth()
            }) {
                ReflectMomentView(
                    modelContext: modelContext,
                    date: viewModel.selectedDate,
                    onClose: { viewModel.showingReflectMoment = false },
                    onSaved: { reflection in
                        viewModel.showingReflectMoment = false
                        showSavedAnimation(for: reflection)
                    }
                )
            }
            .sheet(item: $reflectionToEdit, onDismiss: {
                viewModel.fetchDataForMonth()
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
            
            if showSuccessOverlay {
                SuccessOverlay(
                    title: "Yay, refleksi\nmingguanmu tersimpan!",
                    subtitle: "Ringkasan lengkapmu sudah bisa\ndilihat di arsip",
                    imageName: "RecapDone",
                    primaryButtonTitle: "Lihat Detail",
                    secondaryButtonTitle: "Kembali",
                    highlightRect: nil,
                    onPrimaryAction: {
                        showSuccessOverlay = false
                        if let recap = newlySavedRecap {
                            recapToNavigate = recap
                        }
                    },
                    onSecondaryAction: {
                        showSuccessOverlay = false
                    }
                )
            }
        }
        .navigationDestination(item: $recapToNavigate) { recap in
            DetailRecapMomentView(recap: recap)
        }
        // Cover berlatar bening: overlay menimpa navigation bar, tak menghapusnya.
        .fullScreenCover(item: $savedReflectionForAnimation) { reflection in
            ReflectionSavedView(reflection: reflection, onClose: {
                withoutAnimation { savedReflectionForAnimation = nil }
            })
            .presentationBackground(.clear)
        }
    }
    
    private func showSavedAnimation(for reflection: Reflection) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            viewModel.fetchDataForMonth()
            withoutAnimation { savedReflectionForAnimation = reflection }
        }
    }
    
    private var visibleWeeklyItems: [CalendarHistoryViewModel.WeeklyArchiveItem] {
        viewModel.weeklyArchiveItems.filter { $0.recap != nil || $0.totalReflections > 0 }
    }

    private var weeklySection: some View {
        VStack(spacing: 16) {
            if visibleWeeklyItems.isEmpty {
                emptyWeeklyState
            } else {
                ForEach(visibleWeeklyItems) { item in
                    if let recap = item.recap {
                        CompletedWeeklyCard(
                            recap: recap,
                            weekTitle: "Ringkasan Minggu \(item.weekNumber)",
                            dateRange: item.dateRangeString,
                            totalReflections: item.totalReflections,
                            action: {
                                recapToNavigate = recap
                            }
                        )
                    } else {
                        WeeklyCard(
                            title: "Oops! Tidak ada ringkasan",
                            subtitle: "Klik disini untuk isi refleksi mingguan",
                            dateRange: item.dateRangeString,
                            imageName: "SmallCardRecap",
                            date: item.startDate,
                            modelContext: modelContext,
                            onRecapSaved: {
                                viewModel.fetchDataForMonth()
                                if let updatedItem = viewModel.weeklyArchiveItems.first(where: { $0.weekNumber == item.weekNumber }),
                                   let savedRecap = updatedItem.recap {
                                    newlySavedRecap = savedRecap
                                    showRecapSuccessOverlay()
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var emptyWeeklyState: some View {
        VStack(spacing: 16) {
            HalfSizeImage("EmptyRecap")

            VStack(spacing: 4) {
                Text("Belum ada refleksi bulan ini")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.black)

                Text("Semua rekapmu akan muncul di sini begitu kamu mulai mencatat momen")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private func showRecapSuccessOverlay() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.45))
            withAnimation(.easeIn(duration: 0.2)) {
                showSuccessOverlay = true
            }
        }
    }
    
    private var dailySection: some View {
        VStack(alignment: .leading, spacing: 24) {
            calendarGridView
            
            if !viewModel.selectedDayMoments.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Refleksi Harian")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                    
                    if let reflection = viewModel.selectedDayReflection {
                        ReflectionCard(reflection: reflection, onEdit: {
                            reflectionToEdit = reflection
                        })
                        .padding(.horizontal, -16)
                    } else {
                        Button(action: { viewModel.showingReflectMoment = true }) {
                            HStack(spacing: 12) {
                                Image("NoReflection")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 193.88, height: 137.77)
                                    .scaleEffect(0.95)
                                    .offset(y: 4)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Oops! Tidak ada refleksi")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(.black)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text("Klik disini untuk isi refleksi harian")
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 12)
                                .padding(.trailing, 12)
                                
                                Spacer()
                            }
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Momen Harian (\(viewModel.selectedDayMoments.count))")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                    
                    let columns = [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.selectedDayMoments) { moment in
                            NavigationLink(destination: MomentDetailView(
                                allDayMoments: viewModel.selectedDayMoments,
                                initialMoment: moment,
                                viewModel: createReviewViewModel()
                            )) {
                                MomentCard(moment: moment)
                            }
                        }
                        
                        Button(action: { viewModel.showingCreateMoment = true }) {
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
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Momen Harian")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.black)
                    
                    Button(action: { viewModel.showingCreateMoment = true }) {
                        HStack(spacing: 12) {
                            Image("NoMoment")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 193.88, height: 137.77)
                                .scaleEffect(0.95)
                                .offset(y: 4)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Oops! Tidak ada momen")
                                    .font(.headline.weight(.semibold))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Text("Klik disini untuk tambahkan momen")
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.vertical, 12)
                            .padding(.trailing, 12)
                            
                            Spacer()
                        }
                        .background(Color.white)
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func createReviewViewModel() -> ReviewMomentViewModel {
        let vm = ReviewMomentViewModel()
        vm.modelContext = modelContext
        return vm
    }
    
    private var calendarGridView: some View {
        let daysInMonth = viewModel.daysForMonth()
        let daysOfWeek = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"]
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
        let todayStart = calendar.startOfDay(for: Date())
        
        return VStack(spacing: 12) {
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption.weight(.bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(0..<daysInMonth.count, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        let dayNumber = calendar.component(.day, from: date)
                        let isSelected = calendar.isDate(date, inSameDayAs: viewModel.selectedDate)
                        let isFuture = calendar.startOfDay(for: date) > todayStart
                        let hasReflection = viewModel.monthReflections.contains { calendar.isDate($0.date, inSameDayAs: date) }
                        let dayMomentImage = viewModel.getDayImage(for: date)
                        
                        VStack(spacing: 4) {
                            Button(action: {
                                viewModel.selectedDate = date
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color(.systemGray5))
                                        .frame(width: 42, height: 42)
                                    
                                    if let imageData = dayMomentImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 42, height: 42)
                                            .clipShape(Circle())
                                    }
                                    
                                    if isSelected {
                                        Circle()
                                            .fill(Color.yellow.opacity(0.5))
                                            .frame(width: 42, height: 42)
                                    }
                                    
                                    Text("\(dayNumber)")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(dayMomentImage != nil ? .white : (isFuture ? .gray : .black))
                                        .shadow(color: dayMomentImage != nil ? .black.opacity(0.6) : .clear, radius: 1)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(isFuture)
                            
                            Circle()
                                .fill(hasReflection ? Color.accentColor : Color.clear)
                                .frame(width: 10, height: 10)
                        }
                        .opacity(isFuture ? 0.35 : 1.0)
                    } else {
                        Color.clear
                            .frame(height: 56)
                    }
                }
            }
        }
        .padding(.vertical, 8)
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
