//
//  ReflectMomentViewModelTests.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 17/07/26.
//

import Testing
import Foundation
import SwiftData
@testable import C03A06

@MainActor
@Suite("Select Highlighted Moment (TEC-210)")
struct ReflectMomentViewModelTests {

    // MARK: helper

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    private func date(day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components)!
    }

    private func makeDummyMoment(timestamp: Date) -> Moment {
        Moment(
            photo: Data(),
            timestamp: timestamp,
            shortDescription: "Momen test",
            category: .bermainBersama
        )
    }

    // MARK: assertion 1
    // Given belum memilih momen, ada beberapa momen
    // When halaman Select Moment of the Day dibuka
    // Then tombol lanjut dalam keadaan nonaktif (disabled)

    @Test("Given belum memilih momen dan ada beberapa momen, When halaman dibuka, Then tombol lanjut nonaktif")
    func trailingButtonDisabledWhenNoMomentSelectedYet() throws {
        let context = try makeInMemoryContext()
        let today = date(day: 17)

        let moment1 = makeDummyMoment(timestamp: date(day: 17, hour: 8))
        let moment2 = makeDummyMoment(timestamp: date(day: 17, hour: 14))
        context.insert(moment1)
        context.insert(moment2)
        try context.save()

        let viewModel = ReflectMomentViewModel(date: today)

        // When: halaman dibuka, loadMoments dipanggil
        viewModel.loadMoments(context: context)

        // Then
        #expect(viewModel.moments.count == 2)
        #expect(viewModel.selectedMoment == nil)
        #expect(viewModel.canProceedFromMomentSelection == false)
    }

    // MARK: assertion 2
    // Given belum memilih momen, ada beberapa momen
    // When user memilih salah satu momen
    // Then momen tersebut terpilih, tombol lanjut aktif (enabled)

    @Test("Given ada beberapa momen, When user memilih salah satu, Then momen terpilih dan tombol lanjut aktif")
    func selectingAMomentEnablesTrailingButton() throws {
        let context = try makeInMemoryContext()
        let today = date(day: 17)

        let moment1 = makeDummyMoment(timestamp: date(day: 17, hour: 8))
        let moment2 = makeDummyMoment(timestamp: date(day: 17, hour: 14))
        context.insert(moment1)
        context.insert(moment2)
        try context.save()

        let viewModel = ReflectMomentViewModel(date: today)
        viewModel.loadMoments(context: context)

        // When: user memilih salah satu momen
        viewModel.select(moment1)

        // Then
        #expect(viewModel.selectedMoment?.persistentModelID == moment1.persistentModelID)
        #expect(viewModel.canProceedFromMomentSelection == true)
    }

    // MARK: assertion 3
    // Given tidak ada momen
    // When halaman Select Moment of the Day dibuka
    // Then empty state ditampilkan, tombol lanjut nonaktif

    @Test("Given tidak ada momen sama sekali, When halaman dibuka, Then empty state ditampilkan dan tombol lanjut nonaktif")
    func emptyStateShownAndTrailingButtonDisabledWhenNoMoments() throws {
        let context = try makeInMemoryContext()
        let today = date(day: 17)

        let viewModel = ReflectMomentViewModel(date: today)

        // When: halaman dibuka -> loadMoments dipanggil
        viewModel.loadMoments(context: context)

        // Then
        #expect(viewModel.isEmptyState == true)
        #expect(viewModel.canProceedFromMomentSelection == false)
    }

    // MARK: assertion 4
    // Given user tekan tombol next untuk lanjut page refleksi
    // When user menekan tombol Lanjut
    // Then halaman berpindah ke pertanyaan refleksi, momen yang dipilih tersimpan

    @Test("Given user sudah memilih momen, When user menekan tombol Lanjut, Then halaman berpindah ke pertanyaan dan momen tersimpan")
    func tappingProceedMovesToQuestionStepAndKeepsSelectedMoment() throws {
        let context = try makeInMemoryContext()
        let today = date(day: 17)

        let moment1 = makeDummyMoment(timestamp: date(day: 17, hour: 8))
        let moment2 = makeDummyMoment(timestamp: date(day: 17, hour: 14))
        context.insert(moment1)
        context.insert(moment2)
        try context.save()

        let viewModel = ReflectMomentViewModel(date: today)
        viewModel.loadMoments(context: context)
        viewModel.select(moment2)

        // Given: siap tekan tombol lanjut
        #expect(viewModel.canProceedFromMomentSelection == true)
        #expect(viewModel.step == .selectMoment)

        // When: user menekan tombol Lanjut
        viewModel.proceedToQuestions()

        // Then
        #expect(viewModel.step == .question)
        #expect(viewModel.selectedMoment?.persistentModelID == moment2.persistentModelID)
    }
}

// MARK: TEC-214 (belum ada viewmodel)

enum DummyAnswerType {
    case multipleChoice
    case chip
    case essay
}

enum DummyChoiceType: Equatable {
    case a, b, c
}

struct DummyChoice: Equatable {
    let type: DummyChoiceType
    let text: String
}

struct DummyQuestion {
    let code: String
    let answerType: DummyAnswerType
    var choices: [DummyChoice] = []
    var chipOptions: [String] = []
    var triggerQuestionCode: String? = nil
    var triggerChoiceType: DummyChoiceType? = nil
    var triggerChipValue: String? = nil

    var isFollowUp: Bool { triggerQuestionCode != nil }
}

struct DummyAnswerDraft {
    var selectedChoice: DummyChoice?
    var selectedChip: String?
    var essayText: String?

    var isAnswered: Bool {
        selectedChoice != nil || selectedChip != nil || (essayText?.isEmpty == false)
    }
}

struct QuestionPage: Identifiable {
    let id: String
    let codes: [String]
}

struct QuestionFlowState {
    var allQuestions: [DummyQuestion] = []
    var currentIndex: Int = 0
    var draftAnswers: [String: DummyAnswerDraft] = [:]
    let pageTemplates: [[String]]

    init(pageTemplates: [[String]]) {
        self.pageTemplates = pageTemplates
    }

    private var questionsByCode: [String: DummyQuestion] {
        Dictionary(uniqueKeysWithValues: allQuestions.map { ($0.code, $0) })
    }

    private func isVisible(_ code: String) -> Bool {
        guard let question = questionsByCode[code] else { return false }
        guard question.isFollowUp, let triggerCode = question.triggerQuestionCode else { return true }
        guard let draft = draftAnswers[triggerCode] else { return false }

        if let requiredChoiceType = question.triggerChoiceType {
            return draft.selectedChoice?.type == requiredChoiceType
        }
        if let requiredChipValue = question.triggerChipValue {
            return draft.selectedChip == requiredChipValue
        }
        return false
    }

    var visiblePages: [QuestionPage] {
        pageTemplates.compactMap { template in
            let visibleCodes = template.filter { isVisible($0) }
            guard !visibleCodes.isEmpty else { return nil }
            return QuestionPage(id: template.joined(separator: "-"), codes: visibleCodes)
        }
    }

    var currentPage: QuestionPage? {
        guard visiblePages.indices.contains(currentIndex) else { return nil }
        return visiblePages[currentIndex]
    }

    func questions(in page: QuestionPage) -> [DummyQuestion] {
        page.codes.compactMap { questionsByCode[$0] }
    }

    var isCurrentPageComplete: Bool {
        guard let page = currentPage else { return false }
        return questions(in: page).allSatisfy { question in
            question.answerType == .essay || (draftAnswers[question.code]?.isAnswered ?? false)
        }
    }

    mutating func selectChoice(_ choice: DummyChoice, for code: String) {
        draftAnswers[code] = DummyAnswerDraft(selectedChoice: choice)
    }

    mutating func selectChip(_ chip: String, for code: String) {
        draftAnswers[code] = DummyAnswerDraft(selectedChip: chip)
    }

    mutating func updateEssay(_ text: String, for code: String) {
        var draft = draftAnswers[code] ?? DummyAnswerDraft()
        draft.essayText = text
        draftAnswers[code] = draft
    }

    mutating func goNext() {
        guard isCurrentPageComplete else { return }
        if currentIndex < visiblePages.count - 1 {
            currentIndex += 1
        }
    }

    mutating func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}

@Suite("Answer Daily Reflection Questions (TEC-214)")
struct ReflectMomentQuestionFlowTests {

    // MARK: helper: setup Q1 (multipleChoice) + FQ1 (follow-up, trigger Q1 == C)

    private func makeQ1AndFQ1() -> [DummyQuestion] {
        let q1 = DummyQuestion(
            code: "Q1",
            answerType: .multipleChoice,
            choices: [
                DummyChoice(type: .a, text: "Aku yang memulai"),
                DummyChoice(type: .b, text: "Anakku yang memulai"),
                DummyChoice(type: .c, text: "Orang lain yang memulai")
            ]
        )
        let fq1 = DummyQuestion(
            code: "FQ1",
            answerType: .essay,
            triggerQuestionCode: "Q1",
            triggerChoiceType: .c
        )
        return [q1, fq1]
    }

    // MARK: helper: setup Q5 (chip) + FQ2 (follow-up, trigger Q5 == "Iya")

    private func makeQ5AndFQ2() -> [DummyQuestion] {
        let q5 = DummyQuestion(
            code: "Q5",
            answerType: .chip,
            chipOptions: ["Iya", "Mungkin", "Tidak hari ini"]
        )
        let fq2 = DummyQuestion(
            code: "FQ2",
            answerType: .essay,
            triggerQuestionCode: "Q5",
            triggerChipValue: "Iya"
        )
        return [q5, fq2]
    }

    // MARK: assertion 1
    // Given Q1 (multipleChoice) belum dijawab
    // When halaman pertanyaan dibuka
    // Then tombol lanjut dalam keadaan nonaktif (disabled)

    @Test("Given Q1 belum dijawab, When halaman dibuka, Then tombol lanjut nonaktif")
    func trailingButtonDisabledWhenQuestionNotAnsweredYet() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        #expect(state.isCurrentPageComplete == false)
    }

    // MARK: assertion 2
    // Given Q1 ditampilkan
    // When user memilih salah satu choice
    // Then jawaban tersimpan dan tombol lanjut menjadi aktif (enabled)

    @Test("Given Q1 ditampilkan, When user memilih salah satu choice, Then jawaban tersimpan dan tombol lanjut aktif")
    func selectingChoiceEnablesTrailingButton() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        let choiceA = state.allQuestions[0].choices[0]
        state.selectChoice(choiceA, for: "Q1")

        #expect(state.draftAnswers["Q1"]?.selectedChoice == choiceA)
        #expect(state.isCurrentPageComplete == true)
    }

    // MARK: assertion 3
    // Given Q1 dijawab dengan choice C
    // When halaman-halaman visible dihitung ulang
    // Then FQ1 (follow-up) ikut muncul sebagai halaman berikutnya

    @Test("Given Q1 dijawab choice C, When halaman visible dihitung, Then FQ1 muncul sebagai halaman berikutnya")
    func followUpPageAppearsWhenTriggerConditionMet() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        let choiceC = state.allQuestions[0].choices[2] // .c
        state.selectChoice(choiceC, for: "Q1")

        #expect(state.visiblePages.count == 2)
        #expect(state.visiblePages.last?.codes == ["FQ1"])
    }

    // MARK: assertion 4
    // Given Q1 dijawab dengan choice selain C
    // When halaman-halaman visible dihitung ulang
    // Then FQ1 (follow-up) TIDAK muncul (dilewati)

    @Test("Given Q1 dijawab choice selain C, When halaman visible dihitung, Then FQ1 tidak muncul")
    func followUpPageHiddenWhenTriggerConditionNotMet() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        let choiceA = state.allQuestions[0].choices[0] // .a, bukan .c
        state.selectChoice(choiceA, for: "Q1")

        #expect(state.visiblePages.count == 1)
        #expect(state.visiblePages.first?.codes == ["Q1"])
    }

    // MARK: assertion 5
    // Given halaman hanya berisi pertanyaan essay (opsional)
    // When halaman dibuka tanpa diisi apa pun
    // Then tombol lanjut tetap aktif (essay tidak wajib diisi)

    @Test("Given halaman hanya berisi essay, When halaman dibuka tanpa diisi, Then tombol lanjut tetap aktif")
    func essayOnlyPageIsCompleteEvenWithoutInput() {
        let essayQuestion = DummyQuestion(code: "Q6", answerType: .essay)
        var state = QuestionFlowState(pageTemplates: [["Q6"]])
        state.allQuestions = [essayQuestion]

        #expect(state.isCurrentPageComplete == true)
    }

    // MARK: assertion 6
    // Given user berada di halaman pertama dari dua halaman
    // When user menekan tombol lanjut setelah menjawab
    // Then currentIndex berpindah ke halaman berikutnya

    @Test("Given halaman pertama sudah dijawab, When user menekan tombol lanjut, Then pindah ke halaman berikutnya")
    func goNextMovesToNextPageWhenCurrentPageComplete() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        let choiceC = state.allQuestions[0].choices[2]
        state.selectChoice(choiceC, for: "Q1")

        #expect(state.currentIndex == 0)

        state.goNext()

        #expect(state.currentIndex == 1)
        #expect(state.currentPage?.codes == ["FQ1"])
    }

    // MARK: assertion 7
    // Given user berada di halaman kedua
    // When user menekan tombol kembali
    // Then currentIndex kembali ke halaman sebelumnya

    @Test("Given user di halaman kedua, When user menekan tombol kembali, Then kembali ke halaman sebelumnya")
    func goBackMovesToPreviousPage() {
        var state = QuestionFlowState(pageTemplates: [["Q1"], ["FQ1"]])
        state.allQuestions = makeQ1AndFQ1()

        let choiceC = state.allQuestions[0].choices[2]
        state.selectChoice(choiceC, for: "Q1")
        state.goNext()

        #expect(state.currentIndex == 1)

        state.goBack()

        #expect(state.currentIndex == 0)
        #expect(state.currentPage?.codes == ["Q1"])
    }

    // MARK: assertion 8
    // Given Q5 dijawab dengan chip "Iya"
    // When halaman-halaman visible dihitung ulang
    // Then FQ2 (follow-up) ikut muncul sebagai halaman berikutnya

    @Test("Given Q5 dijawab chip Iya, When halaman visible dihitung, Then FQ2 muncul sebagai halaman berikutnya")
    func fq2AppearsWhenQ5AnsweredIya() {
        var state = QuestionFlowState(pageTemplates: [["Q5"], ["FQ2"]])
        state.allQuestions = makeQ5AndFQ2()

        state.selectChip("Iya", for: "Q5")

        #expect(state.visiblePages.count == 2)
        #expect(state.visiblePages.last?.codes == ["FQ2"])
    }

    // MARK: assertion 9
    // Given Q5 dijawab dengan chip selain "Iya" (misal "Mungkin")
    // When halaman-halaman visible dihitung ulang
    // Then FQ2 (follow-up) TIDAK muncul (dilewati)

    @Test("Given Q5 dijawab chip selain Iya, When halaman visible dihitung, Then FQ2 tidak muncul")
    func fq2HiddenWhenQ5AnsweredSomethingElse() {
        var state = QuestionFlowState(pageTemplates: [["Q5"], ["FQ2"]])
        state.allQuestions = makeQ5AndFQ2()

        state.selectChip("Mungkin", for: "Q5")

        #expect(state.visiblePages.count == 1)
        #expect(state.visiblePages.first?.codes == ["Q5"])
    }

    // MARK: assertion 10
    // Given user sudah menjawab Q5 dengan "Iya" sehingga FQ2 muncul
    // When user mengganti jawaban Q5 menjadi "Tidak hari ini"
    // Then FQ2 otomatis hilang dari daftar halaman visible

    @Test("Given FQ2 sudah muncul karena Q5 = Iya, When user mengganti jawaban Q5 jadi Tidak hari ini, Then FQ2 otomatis hilang")
    func fq2DisappearsWhenQ5AnswerChangedAfterBeingVisible() {
        var state = QuestionFlowState(pageTemplates: [["Q5"], ["FQ2"]])
        state.allQuestions = makeQ5AndFQ2()

        state.selectChip("Iya", for: "Q5")
        #expect(state.visiblePages.count == 2)

        state.selectChip("Tidak hari ini", for: "Q5")

        #expect(state.visiblePages.count == 1)
        #expect(state.visiblePages.first?.codes == ["Q5"])
    }
}
