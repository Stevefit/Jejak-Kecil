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

@Observable
final class ReflectMomentViewModel {

    // MARK: step/navigation state

    private(set) var step: ReflectStep = .selectMoment

    // MARK: TEC-210: moment selection state

    private(set) var moments: [Moment] = []
    private(set) var selectedMoment: Moment?

    private(set) var savedReflection: Reflection?

    // MARK: TEC-214: question state

    private(set) var allQuestions: [Question] = []
    var currentQuestionIndex: Int = 0
    var localDraftAnswers: [String: LocalAnswerDraft] = [:]

    private let date: Date
    private var modelContext: ModelContext

    // MARK: TEC-224: refleksi yang sedang diedit (nil kalau bikin baru)
    private let editingReflection: Reflection?
    private var didPrefillForEditing = false

    var isEditing: Bool {
        editingReflection != nil
    }

    private let pageTemplates: [[String]] = [
        ["Q1", "FQ1"],
        ["Q2"],
        ["Q3"],
        ["Q4", "Q5", "FQ2", "Q6"]
    ]

    init(modelContext: ModelContext, date: Date = .now, editingReflection: Reflection? = nil) {
        self.modelContext = modelContext
        self.date = date
        self.editingReflection = editingReflection
    }

    // MARK: TEC-224: prefill moment & jawaban dari refleksi yang diedit

    func prefillForEditingIfNeeded() {
        guard let reflection = editingReflection, !didPrefillForEditing else { return }
        didPrefillForEditing = true

        selectedMoment = reflection.moment

        var drafts: [String: LocalAnswerDraft] = [:]
        for answer in reflection.answers {
            drafts[answer.question.code] = LocalAnswerDraft(
                selectedChoice: answer.selectedChoice,
                selectedChip: answer.selectedChip,
                essayText: answer.essayText
            )
        }
        localDraftAnswers = drafts
    }

    // MARK: TEC-211: load moment hari ini

    func loadMoments() {
        guard let range = Calendar.current.dayRange(for: date) else {
            print("[ReflectMomentViewModel] loadMoments error: gagal mendapatkan dayRange untuk date \(date)")
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

        do {
            moments = try modelContext.fetch(descriptor)
        } catch {
            print("[ReflectMomentViewModel] loadMoments error: fetch Moment gagal - \(error)")
            moments = []
        }
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
        guard canProceedFromMomentSelection else {
            print("[ReflectMomentViewModel] proceedToQuestions error: belum ada moment yang dipilih (selectedMoment == nil)")
            return
        }
        currentQuestionIndex = 0
        step = .question
    }

    func backToMomentSelection() {
        step = .selectMoment
    }

    // MARK: TEC-214: load & akses bank pertanyaan

    func seedQuestionsIfNeeded() {
        do {
            try QuestionSeeder.seed(in: modelContext)
        } catch {
            print("[ReflectMomentViewModel] seedQuestionsIfNeeded error: QuestionSeeder.seed gagal - \(error)")
        }
    }

    func loadQuestions() {
        let descriptor = FetchDescriptor<Question>(
            sortBy: [SortDescriptor(\.displayOrder, order: .forward)]
        )

        do {
            allQuestions = try modelContext.fetch(descriptor)
        } catch {
            print("[ReflectMomentViewModel] loadQuestions error: fetch Question gagal - \(error)")
            allQuestions = []
        }
    }

    private var allDailyQuestions: [Question] {
        allQuestions.filter { $0.scope == .daily }
    }

    private var questionsByCode: [String: Question] {
        Dictionary(uniqueKeysWithValues: allDailyQuestions.map { ($0.code, $0) })
    }

    // MARK: TEC-214: visibilitas & navigasi halaman

    private func isQuestionVisible(_ code: String) -> Bool {
        guard let question = questionsByCode[code] else {
            print("[ReflectMomentViewModel] isQuestionVisible warning: question dengan code \(code) tidak ditemukan di questionsByCode")
            return false
        }
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
        guard visiblePages.indices.contains(currentQuestionIndex) else {
            print("[ReflectMomentViewModel] isCurrentQuestionPageComplete error: currentQuestionIndex \(currentQuestionIndex) di luar range visiblePages (count: \(visiblePages.count))")
            return false
        }
        let page = visiblePages[currentQuestionIndex]
        return questions(in: page).allSatisfy { question in
            // hanya essay follow-up (FQ1/FQ2) yang opsional; sisanya (termasuk Q6) wajib
            if question.answerType == .essay && question.isFollowUp {
                return true
            }
            return localDraftAnswers[question.code]?.isAnswered ?? false
        }
    }

    var isLastQuestionPage: Bool {
        currentQuestionIndex == visiblePages.count - 1
    }

    func goToNextQuestionPage() {
        guard isCurrentQuestionPageComplete else {
            print("[ReflectMomentViewModel] goToNextQuestionPage error: halaman saat ini belum lengkap dijawab (index: \(currentQuestionIndex))")
            return
        }
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
    // @MainActor karena memanggil BadgeService yang ber-@MainActor.
    @MainActor
    func saveReflection() -> Bool {
        guard let moment = selectedMoment else {
            print("[ReflectMomentViewModel] saveReflection error: selectedMoment nil, refleksi tidak bisa disimpan")
            return false
        }

        let reflection: Reflection
        if let editing = editingReflection {
            // mode edit: pakai refleksi yang ada, ganti moment & hapus jawaban lama
            reflection = editing
            reflection.moment = moment
            reflection.isCompleted = true
            for oldAnswer in reflection.answers {
                modelContext.delete(oldAnswer)
            }
        } else {
            reflection = Reflection(date: date, moment: moment, isCompleted: true)
            modelContext.insert(reflection)
        }

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

            // Jawaban Q1-Q3 baru bisa mengubah lencana pola refleksi minggu ini.
            BadgeService(modelContext: modelContext).evaluateAndSync(weekOf: reflection.date)

            savedReflection = reflection
            step = .completed
            return true
        } catch {
            print("[ReflectMomentViewModel] saveReflection error: modelContext.save() gagal - \(error)")
            return false
        }
    }
}
