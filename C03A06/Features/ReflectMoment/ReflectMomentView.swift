//
//  ReflectMomentView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import SwiftUI
import UIKit
import SwiftData

struct ReflectMomentView: View {
    
    @State private var viewModel: ReflectMomentViewModel
    @State private var showCancelConfirmation = false
    
    private let isEditing: Bool

    let onClose: () -> Void
    let onSaved: (Reflection) -> Void
    
    init(
        modelContext: ModelContext,
        date: Date = .now,
        editingReflection: Reflection? = nil,
        onClose: @escaping () -> Void,
        onSaved: @escaping (Reflection) -> Void = { _ in }
    ) {
        _viewModel = State(
            initialValue: ReflectMomentViewModel(
                modelContext: modelContext,
                date: date,
                editingReflection: editingReflection
            )
        )
        

        self.isEditing = editingReflection != nil
        self.onClose = onClose
        self.onSaved = onSaved
    }
    
    // MARK: body
    
    var body: some View {
        // animasi "Refleksi Tersimpan!" ditampilkan oleh ReviewMomentView (via onSaved)
        // agar background-nya adalah ReviewMomentView, bukan background sheet
        reflectionFlow
            .onChange(of: viewModel.step) { _, newStep in
                if newStep == .completed, let reflection = viewModel.savedReflection {
                    onSaved(reflection)
                }
            }
    }
    
    private var reflectionFlow: some View {
        NavigationStack {
            VStack(spacing: 16) {
                progressBar
                    .padding(.top, 31)
                content
                bottomBar
            }
            .padding(.horizontal)
            .padding(.bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton {
                        showCancelConfirmation = true
                    }
                    //MINDAHIN CONFIRM DIALOGNYA KE BUTTON
                    .confirmationDialog(
                        "Apakah Anda yakin ingin membatalkan refleksi ini?",
                        isPresented: $showCancelConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Batalkan Refleksi", role: .destructive) {
                            onClose()
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("Refleksi Hari ini")
                            .font(.headline)
                        if progressTotal > 0 {
                            Text("\(progressCurrent) dari \(progressTotal)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 34)
                }
                ToolbarItem(placement: .confirmationAction) {
                    SaveButton(isEnabled: isSaveEnabled, action: handleSave)
                }
            }
            
            .task {
                viewModel.seedQuestionsIfNeeded()
                viewModel.loadQuestions()
                viewModel.loadMoments()
                viewModel.prefillForEditingIfNeeded()
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.step {
        case .selectMoment:
            momentSelectionContent
            
        case .question:
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: proxy.size.height * questionTopGapRatio)
                        questionContent
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: proxy.size.height)
                }
            }
            
        case .completed:
            Spacer()
        }
    }
    
    // MARK: progress bar
    
    @ViewBuilder
    private var progressBar: some View {
        if progressTotal > 0 {
            StepProgressBar(current: progressCurrent, total: progressTotal)
        }
    }
    
    // save hanya aktif di halaman pertanyaan terakhir dan semua wajib sudah terjawab
    private var isSaveEnabled: Bool {
        viewModel.step == .question
        && viewModel.isLastQuestionPage
        && viewModel.isCurrentQuestionPageComplete
    }
    
    private func handleSave() {
        viewModel.saveReflection()
    }
    
    private var progressCurrent: Int {
        switch viewModel.step {
        case .selectMoment:
            return 1
        case .question:
            return viewModel.currentQuestionIndex + 2
        case .completed:
            return progressTotal
        }
    }
    
    private var progressTotal: Int {
        1 + viewModel.visiblePages.count
    }
    
    // MARK: bottom navigation (Selanjutnya / Kembali)
    
    @ViewBuilder
    private var bottomBar: some View {
        VStack(spacing: 8) {
            if showPrimaryButton {
                PrimaryButton(
                    title: "Selanjutnya",
                    isEnabled: isPrimaryEnabled,
                    action: handlePrimaryTap
                )
            }
            
            if viewModel.step == .question {
                SecondaryButton(title: "Kembali", action: viewModel.goToPreviousQuestionPage)
            }
        }
    }
    
    private var showPrimaryButton: Bool {
        switch viewModel.step {
        case .selectMoment:
            return true
        case .question:
            return !viewModel.isLastQuestionPage
        case .completed:
            return false
        }
    }
    
    private var isPrimaryEnabled: Bool {
        switch viewModel.step {
        case .selectMoment:
            return viewModel.canProceedFromMomentSelection
        case .question:
            return viewModel.isCurrentQuestionPageComplete
        case .completed:
            return false
        }
    }
    
    private func handlePrimaryTap() {
        switch viewModel.step {
        case .selectMoment:
            viewModel.proceedToQuestions()
        case .question:
            viewModel.goToNextQuestionPage()
        case .completed:
            break
        }
    }
    
    // MARK: TEC-210: select highlighted moment for the day
    
    @ViewBuilder
    private var momentSelectionContent: some View {
        if viewModel.isEmptyState {
            emptyStateView
        } else {
            VStack(spacing: 28) {
                momentPickerHeader
                momentGrid
            }
            .padding(.top, 24)
        }
    }
    
    // MARK: TEC-211: show all moments logged that day (grid)
    
    private var momentPickerHeader: some View {
        VStack(spacing: 5) {
            Text("Pilih Momen Hari Ini")
                .font(.title3.weight(.semibold))
            
            Text("Momen mana yang mau diceritakan?")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    private var momentGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
        
        return ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.moments, id: \.persistentModelID) { moment in
                    SelectableMomentCard(
                        moment: moment,
                        isSelected: viewModel.selectedMoment?.persistentModelID == moment.persistentModelID
                    )
                    .aspectRatio(0.75, contentMode: .fit)
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                    .onTapGesture {
                        viewModel.select(moment)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
    
    // MARK: TEC-213: empty state
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Belum ada momen yang tercatat hari ini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: TEC-214: tampilan halaman pertanyaan (baca state dari ViewModel)
    
    private var questionTopGapRatio: CGFloat {
        guard viewModel.visiblePages.indices.contains(viewModel.currentQuestionIndex) else { return 0.13 }
        let count = viewModel.questions(in: viewModel.visiblePages[viewModel.currentQuestionIndex]).count
        return count >= 3 ? 0.04 : 0.13
    }
    
    @ViewBuilder
    private var questionContent: some View {
        if viewModel.visiblePages.indices.contains(viewModel.currentQuestionIndex) {
            let page = viewModel.visiblePages[viewModel.currentQuestionIndex]
            VStack(alignment: .leading, spacing: 28) {
                ForEach(viewModel.questions(in: page), id: \.persistentModelID) { question in
                    questionInput(for: question, isCombinedPage: page.codes.count > 1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)   // + outer padding 16 = 40 dari tepi layar
            .padding(.bottom, 24)
        }
    }
    
    // MARK: TEC-215 - TEC-222: UI input per pertanyaan
    
    @ViewBuilder
    private func questionInput(for question: Question, isCombinedPage: Bool) -> some View {
        switch question.answerType {
        case .multipleChoice:
            MultipleChoiceSelector(
                question: question,
                selected: viewModel.draft(for: question.code)?.selectedChoice,
                onSelect: { choice in
                    viewModel.selectChoice(choice, for: question.code)
                }
            )
            
        case .chip:
            if isCombinedPage {
                ChipDropdownSelector(
                    question: question,
                    selected: viewModel.draft(for: question.code)?.selectedChip,
                    onSelect: { chip in
                        viewModel.selectChip(chip, for: question.code)
                    }
                )
            } else {
                ChipSelector(
                    question: question,
                    selected: viewModel.draft(for: question.code)?.selectedChip,
                    onSelect: { chip in
                        viewModel.selectChip(chip, for: question.code)
                    }
                )
            }
            
        case .essay:
            EssayInput(
                question: question,
                text: Binding(
                    get: { viewModel.draft(for: question.code)?.essayText ?? "" },
                    set: { viewModel.setEssay($0, for: question.code) }
                )
            )
        }
    }
}

// MARK: animation save reflection

struct ReflectionSavedView: View {
    
    let reflection: Reflection
    let onClose: () -> Void

    // tombol close baru muncul (dan bisa di-tap untuk menutup) setelah jeda ini
    private let dismissEnabledAfter: Double = 3

    // MARK: animasi state
    @State private var showTitle = false
    @State private var showCard = false
    @State private var pulsing = false
    @State private var showButton = false
    
    private var cardScale: CGFloat {
        guard showCard else { return 0.01 }
        return pulsing ? 0.80 : 0.78
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            ConfettiBlast()

            VStack(spacing: 12) {
                Text("Refleksi Tersimpan!")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 6, y: 2)
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : -24)
                
                ReflectionCard(reflection: reflection)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                    .scaleEffect(cardScale)
                    .padding(.top, -24)
                    .padding(.bottom, 8)
                    .opacity(showCard ? 1 : 0)
                
                closeButton
                    .opacity(showButton ? 1 : 0)
                    .scaleEffect(showButton ? 1 : 0.6)
            }
        }
        .onAppear(perform: runAnimation)
        .task {
            try? await Task.sleep(for: .seconds(dismissEnabledAfter))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                showButton = true
            }
        }
    }
    
    // MARK: tombol close
    
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color(.systemBackground)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: koreografi animasi
    
    private func runAnimation() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.65).delay(0.05)) {
            showTitle = true
        }
        withAnimation(.spring(response: 0.34, dampingFraction: 0.55).delay(0.08)) {
            showCard = true
        }
        withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.5)) {
            pulsing = true
        }
    }
}

// MARK: confetti blast

private struct ConfettiBlast: View {

    @State private var animateLeft = false
    @State private var animateRight = false

    var body: some View {
        GeometryReader { geo in
            ZStack {

                Image("ConfettiKiri")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .rotationEffect(.degrees(animateLeft ? -35 : 10))
                    .offset(
                        x: animateLeft ? -40 : -120,
                        y: animateLeft ? geo.size.height + 120 : -250
                    )
                    .opacity(animateLeft ? 0 : 1)

                Image("ConfettiKanan")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .rotationEffect(.degrees(animateRight ? 35 : -10))
                    .offset(
                        x: animateRight ? 40 : 120,
                        y: animateRight ? geo.size.height + 120 : -250
                    )
                    .opacity(animateRight ? 0 : 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {

            withAnimation(.easeOut(duration: 2.4)) {
                animateLeft = true
            }

            withAnimation(.easeOut(duration: 2.4).delay(0.08)) {
                animateRight = true
            }
        }
    }
}

// MARK: preview helper: bikin data foto dummy

private func dummyPhotoData(color: UIColor) -> Data {
    let size = CGSize(width: 300, height: 420)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    return image.pngData() ?? Data()
}

// MARK: preview TEC-211, grid dengan beberapa moment

#Preview("TEC-211: Grid Beberapa Momen") {
    let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let moments = [
        Moment(photo: dummyPhotoData(color: .systemOrange), timestamp: .now, shortDescription: "Bermain di taman", category: .bermainBersama),
        Moment(photo: dummyPhotoData(color: .systemTeal), timestamp: .now, shortDescription: "Ngobrol sebelum tidur", category: .ngobrolDanCerita),
        Moment(photo: dummyPhotoData(color: .systemPurple), timestamp: .now, shortDescription: "Belajar bersama", category: .belajarDanEksplorasi),
        Moment(photo: dummyPhotoData(color: .systemPink), timestamp: .now, shortDescription: "Masak bareng", category: .berkreasiBersama)
    ]
    moments.forEach { container.mainContext.insert($0) }
    
    for question in QuestionSeeder.makeSeedQuestions() {
        container.mainContext.insert(question)
    }
    try? container.mainContext.save()
    
    return Color(.systemGray5)
        .sheet(isPresented: .constant(true)) {
            ReflectMomentView(
                modelContext: container.mainContext,
                onClose: {}
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .modelContainer(container)
}

// MARK: preview TEC-213, empty state

#Preview("TEC-213: Empty State") {
    let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    ReflectMomentView(
        modelContext: container.mainContext,
        onClose: {}
    )
    .modelContainer(container)
}

// MARK: preview TEC-287, animation reflection

#Preview("Animation Reflection") {
    let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let moment = Moment(
        photo: dummyPhotoData(color: .systemOrange),
        timestamp: .now,
        shortDescription: "Main bikin rumah-rumahan sama Lili.",
        category: .bermainBersama
    )
    let reflection = Reflection(date: .now, moment: moment, isCompleted: true)
    
    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Perasaan?", displayOrder: 5)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Perbedaan?", displayOrder: 8)
    reflection.answers = [
        Answer(question: q4, selectedChip: "Hangat", reflection: reflection),
        Answer(question: q6, essayText: "Momen ini terasa hangat dan mengalir.", reflection: reflection)
    ]
    
    container.mainContext.insert(moment)
    container.mainContext.insert(reflection)
    
    return ReflectionSavedView(reflection: reflection, onClose: {})
        .modelContainer(container)
}
