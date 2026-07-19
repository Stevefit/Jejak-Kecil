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
