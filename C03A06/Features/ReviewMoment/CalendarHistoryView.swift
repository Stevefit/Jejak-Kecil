import SwiftUI
import SwiftData

struct CalendarHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Dideklarasikan tipenya saja (tanpa langsung diisi) agar kita bisa
    // melakukan inisialisasi manual dan memasukkan parameter (initialTab).
    @State private var viewModel: CalendarHistoryViewModel
    private var calendar: Calendar { Calendar.current }
    
    // Mengambil nilai initialTab dari parent view dan meracik ViewModel-nya.
    init(initialTab: Int = 1) {
        _viewModel = State(initialValue: CalendarHistoryViewModel(initialTab: initialTab))
    }
    
    @State private var showSuccessOverlay = false
    @State private var newlySavedRecap: Recap? = nil
    @State private var recapToNavigate: Recap? = nil
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                Picker("", selection: $viewModel.selectedTab) {
                    Text("Mingguan").tag(0)
                    Text("Harian").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                DatePickerLabel(title: viewModel.formattedMonthYear) {
                    viewModel.showingDatePicker = true
                }
                .padding(.horizontal, 16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.selectedTab == 0 {
                            weeklySection
                        } else {
                            dailySection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
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
                CreateMomentView()  
            }
            .sheet(isPresented: $viewModel.showingReflectMoment, onDismiss: {
                viewModel.fetchDataForMonth()
            }) {
                ReflectMomentView(
                    modelContext: modelContext,
                    date: viewModel.selectedDate,
                    onClose: { viewModel.showingReflectMoment = false }
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
    }
    private var weeklySection: some View {
        VStack(spacing: 16) {
            if viewModel.weeklyArchiveItems.isEmpty {
                Text("Tidak ada minggu di bulan ini.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(viewModel.weeklyArchiveItems) { item in
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
                            title: "Oops! Tidak\nada ringkasan",
                            subtitle: "Klik disini untuk isi\nrefleksi mingguan",
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
    
    // tampilkan overlay sukses setelah sheet Recap selesai ditutup
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
                        ReflectionCard(reflection: reflection)
                    } else {
                        Button(action: { viewModel.showingReflectMoment = true }) {
                            HStack(spacing: 12) {
                                Image("Noreflectionmoment")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: .infinity)
                                
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
                            .frame(minHeight: 110)
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
                            // PERBAIKAN: Gunakan ReviewMomentViewModel yang ter-inject modelContext
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
                            Image("Noreflectionmoment")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: .infinity)
                            
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
                        .frame(minHeight: 110)
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
                                        .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray5))
                                        .frame(width: 42, height: 42)
                                    
                                    if isSelected {
                                        Circle()
                                            .stroke(Color.blue, lineWidth: 2)
                                            .frame(width: 42, height: 42)
                                    }
                                    
                                    if let imageData = dayMomentImage, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
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
                                .frame(width: 11, height: 11)
                        }
                        .opacity(isFuture ? 0.35 : 1.0)
                    } else {
                        Color.clear
                            .frame(height: 52)
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
