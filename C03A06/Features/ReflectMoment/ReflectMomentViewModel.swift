//
//  ReflectMomentViewModel.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 18/07/26.
//

import Foundation
import SwiftData

enum ReflectStep: Equatable {
    case selectMoment
    case question
    case completed
}

struct LocalQuestionPage: Identifiable {
    let id: String
    let codes: [String]
}

struct LocalAnswerDraft {
    var selectedChoice: Choice?
    var selectedChip: String?
    var essayText: String?

    var isAnswered: Bool {
        selectedChoice != nil || selectedChip != nil || (essayText?.isEmpty == false)
    }
}

@MainActor
@Observable
final class ReflectMomentViewModel {

    // MARK: step/navigation state

    private(set) var step: ReflectStep = .selectMoment

    // MARK: TEC-210: moment selection state

    private(set) var moments: [Moment] = []
    private(set) var selectedMoment: Moment?

    // MARK: TEC-214: question state

    private(set) var allQuestions: [Question] = []
    var currentQuestionIndex: Int = 0
    var localDraftAnswers: [String: LocalAnswerDraft] = [:]

    private let date: Date
    private var modelContext: ModelContext

    private let pageTemplates: [[String]] = [
        ["Q1", "FQ1"],
        ["Q2"],
        ["Q3"],
        ["Q4", "Q5", "FQ2", "Q6"]
    ]

    init(modelContext: ModelContext, date: Date = .now) {
        self.modelContext = modelContext
        self.date = date
    }

    // MARK: TEC-211: load moment hari ini

    func loadMoments() {
        guard let range = Calendar.current.dayRange(for: date) else {
            moments = []
            return
        }
        let start = range.lowerBound
        let end = range.upperBound

        let descriptor = FetchDescriptor<Moment>(
            predicate: #Predicate { moment in
                moment.timestamp >= start && moment.timestamp < end
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        moments = (try? modelContext.fetch(descriptor)) ?? []
    }

    func select(_ moment: Moment) {
        selectedMoment = moment
    }

    // MARK: TEC-213: empty state

    var isEmptyState: Bool {
        moments.isEmpty
    }

    // MARK: tombol next lanjut/ga

    var canProceedFromMomentSelection: Bool {
        selectedMoment != nil
    }

    // MARK: transisi step

    func proceedToQuestions() {
        guard canProceedFromMomentSelection else { return }
        currentQuestionIndex = 0
        step = .question
    }

    func backToMomentSelection() {
        step = .selectMoment
    }

    // MARK: TEC-214: load & akses bank pertanyaan

    func loadQuestions() {
        let descriptor = FetchDescriptor<Question>(
            sortBy: [SortDescriptor(\.displayOrder, order: .forward)]
        )
        allQuestions = (try? modelContext.fetch(descriptor)) ?? []
    }

    private var allDailyQuestions: [Question] {
        allQuestions.filter { $0.scope == .daily }
    }

    private var questionsByCode: [String: Question] {
        Dictionary(uniqueKeysWithValues: allDailyQuestions.map { ($0.code, $0) })
    }

    // MARK: TEC-214: visibilitas & navigasi halaman

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

    var visiblePages: [LocalQuestionPage] {
        pageTemplates.compactMap { template in
            let visibleCodes = template.filter { isQuestionVisible($0) }
            guard !visibleCodes.isEmpty else { return nil }
            return LocalQuestionPage(id: template.joined(separator: "-"), codes: visibleCodes)
        }
    }

    func questions(in page: LocalQuestionPage) -> [Question] {
        page.codes.compactMap { questionsByCode[$0] }
    }

    var isCurrentQuestionPageComplete: Bool {
        guard visiblePages.indices.contains(currentQuestionIndex) else { return false }
        let page = visiblePages[currentQuestionIndex]
        return questions(in: page).allSatisfy { question in
            question.answerType == .essay || (localDraftAnswers[question.code]?.isAnswered ?? false)
        }
    }

    var isLastQuestionPage: Bool {
        currentQuestionIndex == visiblePages.count - 1
    }

    func goToNextQuestionPage() {
        guard isCurrentQuestionPageComplete else { return }
        if currentQuestionIndex < visiblePages.count - 1 {
            currentQuestionIndex += 1
        }
    }

    func goToPreviousQuestionPage() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        } else {
            backToMomentSelection()
        }
    }

    // MARK: TEC-214: update draft jawaban

    func draft(for code: String) -> LocalAnswerDraft? {
        localDraftAnswers[code]
    }

    func selectChoice(_ choice: Choice, for code: String) {
        localDraftAnswers[code] = LocalAnswerDraft(selectedChoice: choice)
    }

    func selectChip(_ chip: String, for code: String) {
        localDraftAnswers[code] = LocalAnswerDraft(selectedChip: chip)
    }

    func setEssay(_ text: String, for code: String) {
        var draft = localDraftAnswers[code] ?? LocalAnswerDraft()
        draft.essayText = text
        localDraftAnswers[code] = draft
    }

    // MARK: TEC-214: simpan refleksi ke database

    @discardableResult
    func saveReflection() -> Bool {
        guard let moment = selectedMoment else { return false }

        let reflection = Reflection(date: date, moment: moment, isCompleted: true)
        modelContext.insert(reflection)

        for page in visiblePages {
            for question in questions(in: page) {
                guard let draft = localDraftAnswers[question.code], draft.isAnswered else { continue }
                let answer = Answer(
                    question: question,
                    selectedChoice: draft.selectedChoice,
                    selectedChip: draft.selectedChip,
                    essayText: draft.essayText,
                    reflection: reflection
                )
                modelContext.insert(answer)
            }
        }

        do {
            try modelContext.save()
            step = .completed
            return true
        } catch {
            return false
        }
    }
}
