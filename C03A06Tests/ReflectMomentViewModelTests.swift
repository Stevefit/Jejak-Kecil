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

        let viewModel = ReflectMomentViewModel(modelContext: context, date: today)

        // When: halaman dibuka, loadMoments dipanggil
        viewModel.loadMoments()

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

        let viewModel = ReflectMomentViewModel(modelContext: context, date: today)
        viewModel.loadMoments()

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

        let viewModel = ReflectMomentViewModel(modelContext: context, date: today)

        // When: halaman dibuka -> loadMoments dipanggil
        viewModel.loadMoments()

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

        let viewModel = ReflectMomentViewModel(modelContext: context, date: today)
        viewModel.loadMoments()
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

// MARK: TEC-214 (sudah vm)

@MainActor
@Suite("Answer Daily Reflection Questions - ViewModel (TEC-214)")
struct ReflectMomentQuestionViewModelTests {

    // MARK: helper

    private func makeContextWithQuestions() throws -> ModelContext {
        let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        let context = ModelContext(container)
        for question in QuestionSeeder.makeSeedQuestions() {
            context.insert(question)
        }
        try context.save()
        return context
    }

    private func makeViewModel(context: ModelContext) -> ReflectMomentViewModel {
        let viewModel = ReflectMomentViewModel(modelContext: context)
        viewModel.loadQuestions()
        return viewModel
    }

    private func choice(_ type: ChoiceType, in viewModel: ReflectMomentViewModel, questionCode: String) -> Choice {
        let question = viewModel.allQuestions.first { $0.code == questionCode }!
        return question.choices.first { $0.type == type }!
    }

    // MARK: assertion 1
    // Given Q1 (multipleChoice) belum dijawab
    // When halaman pertanyaan dibuka
    // Then tombol lanjut nonaktif (halaman belum lengkap)

    @Test("Given Q1 belum dijawab, When halaman dibuka, Then halaman belum lengkap (tombol lanjut nonaktif)")
    func trailingButtonDisabledWhenQuestionNotAnsweredYet() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        #expect(viewModel.isCurrentQuestionPageComplete == false)
    }

    // MARK: assertion 2
    // Given Q1 ditampilkan
    // When user memilih salah satu choice
    // Then jawaban tersimpan dan halaman menjadi lengkap (tombol lanjut aktif)

    @Test("Given Q1 ditampilkan, When user memilih salah satu choice, Then jawaban tersimpan dan halaman lengkap")
    func selectingChoiceEnablesTrailingButton() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        let choiceA = choice(.a, in: viewModel, questionCode: "Q1")
        viewModel.selectChoice(choiceA, for: "Q1")

        #expect(viewModel.draft(for: "Q1")?.selectedChoice?.persistentModelID == choiceA.persistentModelID)
        #expect(viewModel.isCurrentQuestionPageComplete == true)
    }

    // MARK: assertion 3
    // Given Q1 dijawab dengan choice C ("Orang lain yang memulai")
    // When daftar halaman visible dihitung
    // Then FQ1 (follow-up) ikut muncul di halaman pertama

    @Test("Given Q1 dijawab choice C, When halaman visible dihitung, Then FQ1 ikut muncul di halaman pertama")
    func followUpAppearsWhenTriggerConditionMet() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChoice(choice(.c, in: viewModel, questionCode: "Q1"), for: "Q1")

        #expect(viewModel.visiblePages.first?.codes == ["Q1", "FQ1"])
    }

    // MARK: assertion 4
    // Given Q1 dijawab dengan choice selain C
    // When daftar halaman visible dihitung
    // Then FQ1 TIDAK muncul (hanya Q1 di halaman pertama)

    @Test("Given Q1 dijawab choice selain C, When halaman visible dihitung, Then FQ1 tidak muncul")
    func followUpHiddenWhenTriggerConditionNotMet() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q1"), for: "Q1")

        #expect(viewModel.visiblePages.first?.codes == ["Q1"])
    }

    
    // MARK: assertion 5
    // Given halaman terakhir memuat essay Q6 (wajib)
    // When Q4 & Q5 dijawab tapi Q6 dibiarkan kosong
    // Then halaman belum lengkap; setelah Q6 diisi, halaman menjadi lengkap

    @Test("Given halaman terakhir ada essay Q6 wajib, When Q4 & Q5 dijawab tapi Q6 kosong, Then belum lengkap sampai Q6 diisi")
    func essayQ6IsRequiredForPageCompletion() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        // Lewati halaman-halaman wajib menuju halaman terakhir.
        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q1"), for: "Q1")
        viewModel.goToNextQuestionPage()
        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q2"), for: "Q2")
        viewModel.goToNextQuestionPage()
        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q3"), for: "Q3")
        viewModel.goToNextQuestionPage()

        // Halaman terakhir: jawab chip Q4 & Q5, biarkan essay Q6 kosong.
        viewModel.selectChip("Hangat", for: "Q4")
        viewModel.selectChip("Mungkin", for: "Q5")

        #expect(viewModel.isLastQuestionPage == true)
        // Q6 wajib diisi, jadi halaman belum lengkap selama Q6 kosong.
        #expect(viewModel.isCurrentQuestionPageComplete == false)

        // Setelah Q6 diisi, halaman menjadi lengkap.
        viewModel.setEssay("Momennya terasa lebih hangat dari biasanya", for: "Q6")
        #expect(viewModel.isCurrentQuestionPageComplete == true)
    }

    // MARK: assertion 6
    // Given halaman pertama sudah dijawab
    // When user menekan lanjut
    // Then currentQuestionIndex berpindah ke halaman berikutnya

    @Test("Given halaman pertama sudah dijawab, When goToNextQuestionPage, Then pindah ke halaman berikutnya")
    func goNextMovesToNextPage() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q1"), for: "Q1")
        #expect(viewModel.currentQuestionIndex == 0)

        viewModel.goToNextQuestionPage()
        #expect(viewModel.currentQuestionIndex == 1)
    }

    // MARK: assertion 7
    // Given user berada di halaman kedua
    // When user menekan kembali
    // Then currentQuestionIndex kembali ke halaman sebelumnya

    @Test("Given user di halaman kedua, When goToPreviousQuestionPage, Then kembali ke halaman sebelumnya")
    func goBackMovesToPreviousPage() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChoice(choice(.a, in: viewModel, questionCode: "Q1"), for: "Q1")
        viewModel.goToNextQuestionPage()
        #expect(viewModel.currentQuestionIndex == 1)

        viewModel.goToPreviousQuestionPage()
        #expect(viewModel.currentQuestionIndex == 0)
    }

    // MARK: assertion 8
    // Given Q5 dijawab dengan chip "Iya"
    // When daftar halaman visible dihitung
    // Then FQ2 (follow-up) ikut muncul di halaman terakhir

    @Test("Given Q5 dijawab chip Iya, When halaman visible dihitung, Then FQ2 muncul di halaman terakhir")
    func fq2AppearsWhenQ5Iya() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChip("Iya", for: "Q5")

        #expect(viewModel.visiblePages.last?.codes == ["Q4", "Q5", "FQ2", "Q6"])
    }

    // MARK: assertion 9
    // Given Q5 dijawab dengan chip selain "Iya"
    // When daftar halaman visible dihitung
    // Then FQ2 TIDAK muncul di halaman terakhir

    @Test("Given Q5 dijawab chip selain Iya, When halaman visible dihitung, Then FQ2 tidak muncul")
    func fq2HiddenWhenQ5NotIya() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChip("Mungkin", for: "Q5")

        #expect(viewModel.visiblePages.last?.codes == ["Q4", "Q5", "Q6"])
    }

    // MARK: assertion 10
    // Given FQ2 sudah muncul karena Q5 = "Iya"
    // When user mengganti jawaban Q5 menjadi "Tidak hari ini"
    // Then FQ2 otomatis hilang dari halaman terakhir

    @Test("Given FQ2 sudah muncul karena Q5 = Iya, When Q5 diganti jadi Tidak hari ini, Then FQ2 otomatis hilang")
    func fq2DisappearsWhenQ5Changed() throws {
        let context = try makeContextWithQuestions()
        let viewModel = makeViewModel(context: context)

        viewModel.selectChip("Iya", for: "Q5")
        #expect(viewModel.visiblePages.last?.codes == ["Q4", "Q5", "FQ2", "Q6"])

        viewModel.selectChip("Tidak hari ini", for: "Q5")
        #expect(viewModel.visiblePages.last?.codes == ["Q4", "Q5", "Q6"])
    }
}
