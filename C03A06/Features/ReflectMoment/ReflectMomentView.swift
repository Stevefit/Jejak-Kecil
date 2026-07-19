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

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ReflectMomentViewModel
    let onClose: () -> Void

    init(date: Date = .now, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: ReflectMomentViewModel(date: date))
        self.onClose = onClose
    }

    // MARK: TEC-214: answer daily reflection questions

    @Query(sort: \Question.displayOrder)
    private var allQuestions: [Question]

    private var allDailyQuestions: [Question] {
        allQuestions.filter { $0.scope == .daily }
    }

    @State private var currentQuestionIndex: Int = 0
    @State private var localDraftAnswers: [String: LocalAnswerDraft] = [:]

    private let pageTemplates: [[String]] = [
        ["Q1", "FQ1"],
        ["Q2"],
        ["Q3"],
        ["Q4", "Q5", "FQ2", "Q6"]
    ]

    // MARK: body

    var body: some View {
        VStack(spacing: 16) {
            header

            switch viewModel.step {
            case .selectMoment:
                Spacer()
                momentSelectionContent
                Spacer()

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
                EmptyView()
                Spacer()
            }
        }
        .padding()
        .task {
            // Jaring pengaman: pastikan bank pertanyaan ter-seed sebelum halaman pertanyaan.
            try? QuestionSeeder.seed(in: modelContext)
            viewModel.loadMoments(context: modelContext)
        }
    }

    // MARK: header

    private var header: some View {
        NavigationHeaderBar(
            title: "Refleksi Hari ini",
            leadingIcon: leadingIcon,
            onLeadingTap: handleLeadingTap,
            trailingIcon: trailingIcon,
            trailingColor: trailingColor,
            trailingForegroundColor: trailingForegroundColor,
            isTrailingEnabled: isTrailingEnabled,
            onTrailingTap: handleTrailingTap,
            progressCurrent: progressCurrent,
            progressTotal: progressTotal
        )
    }

    private var leadingIcon: String {
        viewModel.step == .selectMoment ? "xmark" : "chevron.left"
    }

    private var isLastQuestionPage: Bool {
        currentQuestionIndex == visiblePages.count - 1
    }

    private var trailingIcon: String {
        if viewModel.step == .question, isLastQuestionPage {
            return "checkmark"
        }
        return "chevron.right"
    }

    private var trailingColor: Color {
        if viewModel.step == .question, isLastQuestionPage {
            return .blue
        }
        return Color(.systemGray6)
    }

    private var trailingForegroundColor: Color {
        if viewModel.step == .question, isLastQuestionPage {
            return .white
        }
        return .primary
    }

    private var isTrailingEnabled: Bool {
        switch viewModel.step {
        case .selectMoment:
            return viewModel.canProceedFromMomentSelection
        case .question:
            return isCurrentQuestionPageComplete
        case .completed:
            return false
        }
    }

    private var progressCurrent: Int {
        switch viewModel.step {
        case .selectMoment:
            return 1
        case .question:
            return currentQuestionIndex + 2
        case .completed:
            return progressTotal
        }
    }

    private var progressTotal: Int {
        1 + visiblePages.count
    }

    private func handleLeadingTap() {
        switch viewModel.step {
        case .selectMoment:
            onClose()
        case .question:
            goToPreviousQuestionPage()
        case .completed:
            onClose()
        }
    }

    private func handleTrailingTap() {
        switch viewModel.step {
        case .selectMoment:
            viewModel.proceedToQuestions()
            currentQuestionIndex = 0
        case .question:
            goToNextQuestionPage()
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

    // MARK: TEC-211: show all moments logged that day (carousel)

    private var momentPickerView: some View {
        VStack(spacing: 28) {

            VStack(spacing: 6) {
                Text("Pilih Momen Hari Ini")
                    .font(.title3.weight(.semibold))

                Text("Momen mana yang mau diceritakan?")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            momentCarousel
        }
    }

    // carousel horizontal, kartu di tengah otomatis lebih besar
    private var momentCarousel: some View {
        let cardWidth: CGFloat = 210
        let cardHeight: CGFloat = 300
        let spacing: CGFloat = 28

        return GeometryReader { geometry in
            let sideInset = (geometry.size.width - cardWidth) / 2

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(viewModel.moments, id: \.persistentModelID) { moment in
                        SelectableMomentCard(
                            moment: moment,
                            isSelected: viewModel.selectedMoment?.persistentModelID == moment.persistentModelID
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                .opacity(phase.isIdentity ? 1 : 0.6)
                        }
                        .onTapGesture {
                            viewModel.select(moment)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sideInset)
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(height: cardHeight)
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

    // MARK: TEC-214: navigasi & visibilitas halaman pertanyaan

    private var questionsByCode: [String: Question] {
        Dictionary(uniqueKeysWithValues: allDailyQuestions.map { ($0.code, $0) })
    }

    private func isQuestionVisible(_ code: String) -> Bool {
        guard let question = questionsByCode[code] else { return false }
        guard question.isFollowUp, let triggerCode = question.triggerQuestionCode else { return true }
        guard let draft = localDraftAnswers[triggerCode] else { return false }

        if let requiredChoiceType = question.triggerChoiceType {
            return draft.selectedChoice?.type == requiredChoiceType
        }
        if let requiredChipValue = question.triggerChipValue {
            return draft.selectedChip == requiredChipValue
        }
        return false
    }

    private var visiblePages: [LocalQuestionPage] {
        pageTemplates.compactMap { template in
            let visibleCodes = template.filter { isQuestionVisible($0) }
            guard !visibleCodes.isEmpty else { return nil }
            return LocalQuestionPage(id: template.joined(separator: "-"), codes: visibleCodes)
        }
    }

    private func questions(in page: LocalQuestionPage) -> [Question] {
        page.codes.compactMap { questionsByCode[$0] }
    }

    private var isCurrentQuestionPageComplete: Bool {
        guard visiblePages.indices.contains(currentQuestionIndex) else { return false }
        let page = visiblePages[currentQuestionIndex]
        return questions(in: page).allSatisfy { question in
            question.answerType == .essay || (localDraftAnswers[question.code]?.isAnswered ?? false)
        }
    }

    private func goToNextQuestionPage() {
        guard isCurrentQuestionPageComplete else { return }
        if currentQuestionIndex < visiblePages.count - 1 {
            currentQuestionIndex += 1
        }
    }

    private func goToPreviousQuestionPage() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        } else {
            viewModel.backToMomentSelection()
        }
    }

    private var questionTopGapRatio: CGFloat {
        guard visiblePages.indices.contains(currentQuestionIndex) else { return 0.13 }
        let count = questions(in: visiblePages[currentQuestionIndex]).count
        return count >= 3 ? 0.04 : 0.13
    }

    @ViewBuilder
    private var questionContent: some View {
        if visiblePages.indices.contains(currentQuestionIndex) {
            let page = visiblePages[currentQuestionIndex]
            VStack(alignment: .leading, spacing: 28) {
                ForEach(questions(in: page), id: \.persistentModelID) { question in
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
                selected: localDraftAnswers[question.code]?.selectedChoice,
                onSelect: { choice in
                    localDraftAnswers[question.code] = LocalAnswerDraft(selectedChoice: choice)
                }
            )

        case .chip:
            if isCombinedPage {
                ChipDropdownSelector(
                    question: question,
                    selected: localDraftAnswers[question.code]?.selectedChip,
                    onSelect: { chip in
                        localDraftAnswers[question.code] = LocalAnswerDraft(selectedChip: chip)
                    }
                )
            } else {
                ChipSelector(
                    question: question,
                    selected: localDraftAnswers[question.code]?.selectedChip,
                    onSelect: { chip in
                        localDraftAnswers[question.code] = LocalAnswerDraft(selectedChip: chip)
                    }
                )
            }

        case .essay:
            EssayInput(
                question: question,
                text: Binding(
                    get: { localDraftAnswers[question.code]?.essayText ?? "" },
                    set: { text in
                        var draft = localDraftAnswers[question.code] ?? LocalAnswerDraft()
                        draft.essayText = text
                        localDraftAnswers[question.code] = draft
                    }
                )
            )
        }
    }
}

// MARK: struct pendukung halaman pertanyaan (TEC-214)

private struct LocalQuestionPage: Identifiable {
    let id: String
    let codes: [String]
}

private struct LocalAnswerDraft {
    var selectedChoice: Choice?
    var selectedChip: String?
    var essayText: String?

    var isAnswered: Bool {
        selectedChoice != nil || selectedChip != nil || (essayText?.isEmpty == false)
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
            ReflectMomentView(onClose: {})
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

    return ReflectMomentView(onClose: {})
        .modelContainer(container)
}
