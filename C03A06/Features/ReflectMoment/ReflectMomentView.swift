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
    let onClose: () -> Void

    init(
        modelContext: ModelContext,
        date: Date = .now,
        onClose: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: ReflectMomentViewModel(
                modelContext: modelContext,
                date: date
            )
        )

        self.onClose = onClose
    }
    // MARK: body

    var body: some View {
        VStack(spacing: 16) {
            header
            content
            bottomBar
        }
        .padding()
        .confirmationDialog(
            "Apakah Anda yakin ingin membatalkan refleksi ini?",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("Batalkan Refleksi", role: .destructive) {
                onClose()
            }
        }
        .task {
            viewModel.seedQuestionsIfNeeded()
            viewModel.loadQuestions()
            viewModel.loadMoments()
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

    // MARK: header

    private var header: some View {
        NavigationHeaderBar(
            title: "Refleksi Hari ini",
            leadingIcon: "xmark",
            onLeadingTap: { showCancelConfirmation = true },
            trailingIcon: "checkmark",
            trailingColor: .blue,
            trailingForegroundColor: .white,
            isTrailingEnabled: isSaveEnabled,
            onTrailingTap: handleSave,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal
        )
    }

    // save hanya aktif di halaman pertanyaan terakhir dan semua wajib sudah terjawab
    private var isSaveEnabled: Bool {
        viewModel.step == .question
            && viewModel.isLastQuestionPage
            && viewModel.isCurrentQuestionPageComplete
    }

    private func handleSave() {
        viewModel.saveReflection()
        onClose()
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
        VStack(spacing: 12) {
            if showPrimaryButton {
                Button(action: handlePrimaryTap) {
                    Text("Selanjutnya")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isPrimaryEnabled ? Color.blue : Color(.systemGray4))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isPrimaryEnabled)
            }

            if viewModel.step == .question {
                Button("Kembali", action: viewModel.goToPreviousQuestionPage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
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
            momentPickerView
        }
    }

    // MARK: TEC-211: show all moments logged that day (grid)

    private var momentPickerView: some View {
        VStack(spacing: 28) {

            VStack(spacing: 6) {
                Text("Pilih Momen Hari Ini")
                    .font(.title3.weight(.semibold))

                Text("Momen mana yang mau diceritakan?")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            momentGrid
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
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Belum ada momen yang tercatat hari ini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
            .padding(.horizontal, 8)
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

// MARK: preview TEC-211, carousel dengan beberapa moment

#Preview("TEC-211: Carousel Beberapa Momen") {
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
