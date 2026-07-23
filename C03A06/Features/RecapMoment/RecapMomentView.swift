//
//  RecapMomentView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
import SwiftUI
import SwiftData

struct RecapMomentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: RecapMomentViewModel
    @State private var currentPage: Int = 1
    @State private var showCancelAlert: Bool = false
    
    private let totalPage: Int = 2
    private let gridColumns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    init(modelContext: ModelContext, date: Date = .now) {
        _viewModel = State(initialValue: RecapMomentViewModel(modelContext: modelContext, date: date))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                switch currentPage {
                case 1: wq1Content
                default: wq2Content
                }
            }
            .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
            
            //MARK: Step Progress Bar + sticky header WQ1
            .safeAreaInset(edge: .top) {
                VStack(spacing: 16) {
                    StepProgressBar(current: currentPage, total: totalPage)
                        .padding(.top, 31)
                    if currentPage == 1 { wq1Header }
                }
                .padding(.horizontal, 25)
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: TOOL BAR
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Tutup", systemImage: "xmark") {
                        if viewModel.hasChanges {
                            showCancelAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .confirmationDialog(
                        "Apakah Anda yakin ingin membatalkan refleksi minggu ini?",
                        isPresented: $showCancelAlert,
                        titleVisibility: .visible
                    ) {
                        Button("Batalkan", role: .destructive) { dismiss() }
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Refleksi Mingguan")
                            .font(.headline)
                        Text("\(currentPage) dari \(totalPage)")
                            .font(.footnote)
                    }
                    .padding(.top, 34)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Simpan", systemImage: "checkmark") {
                        if viewModel.saveRecap() { dismiss() }
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.canSave)
                }
            }
            .interactiveDismissDisabled(viewModel.hasChanges)
            
            //MARK: Bottom navigation
            .safeAreaInset(edge: .bottom) {
                if currentPage == 1 {
                    PrimaryButton(
                        title: "Selanjutnya",
                        isEnabled: viewModel.isReflectionSelected,
                        action: { currentPage = 2 }
                    )
                } else {
                    SecondaryButton(title: "Kembali") { currentPage = 1 }
                        .padding(.bottom)
                }
            }
            .task {
                viewModel.seedQuestionsIfNeeded()
                viewModel.loadWeeklyReflections()
                viewModel.loadWQ2()
            }
        }
    }
    
    // MARK: WQ1 — header (sticky di bawah progress bar)
    private var wq1Header: some View {
        VStack(spacing: 6) {
            Text("Pilih Refleksi Minggu Ini")
                .font(.headline)
                .fontWeight(.semibold)
            Text("Momen apa yang paling berkesan bagi Anda minggu ini?")
                .font(.subheadline)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: WQ1 — pilih refleksi minggu ini
    private var wq1Content: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(viewModel.weeklyReflections, id: \.persistentModelID) { reflection in
                SelectableReflectionCard(
                    reflection: reflection,
                    isSelected: viewModel.selectedReflection?.persistentModelID == reflection.persistentModelID
                )
                .onTapGesture { viewModel.select(reflection) }
            }
        }
        .padding()
    }
    
    // MARK: WQ2 — jawaban essay
    @ViewBuilder
    private var wq2Content: some View {
        if let question = viewModel.wq2Question {
            VStack(alignment: .leading, spacing: 12) {
                Text(question.text)
                    .font(.headline)
                
                TextField(
                    "Maksimal \(RecapMomentViewModel.essayMaxLength) karakter",
                    text: $viewModel.essayText,
                    axis: .vertical
                )
                .lineLimit(4, reservesSpace: true)
                .padding(16)
                .background(Color.white, in: .rect(cornerRadius: 24))
                .onChange(of: viewModel.essayText) { _, newValue in
                    if newValue.count > RecapMomentViewModel.essayMaxLength {
                        viewModel.essayText = String(newValue.prefix(RecapMomentViewModel.essayMaxLength))
                    }
                }
            }
            .padding(30)
        }
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 160, height: 160))
    let dummyImage = renderer.jpegData(withCompressionQuality: 1.0) { context in
        UIColor.systemOrange.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 160, height: 160))
    }
    for i in 0..<6 {
        let moment = Moment(photo: dummyImage, timestamp: .now, shortDescription: "Main bikin rumah-rumahan sama Lili \(i)", category: .bermainBersama)
        container.mainContext.insert(Reflection(date: .now, moment: moment, isCompleted: true))
    }
    
    return Color(.systemGray5)
        .sheet(isPresented: .constant(true)) {
            RecapMomentView(modelContext: container.mainContext)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .modelContainer(container)
}
