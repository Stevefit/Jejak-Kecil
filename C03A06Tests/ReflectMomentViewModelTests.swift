//
//  ReflectMomentViewModelTests.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 17/07/26.
//

import Testing
import Foundation
@testable import C03A06

@Suite("Select Highlighted Moment (TEC-210)")
struct ReflectMomentViewModelTests {

    // MARK: assertion 1
    // Given belum memilih momen, ada beberapa momen
    // When halaman Select Moment of the Day dibuka
    // Then tombol lanjut dalam keadaan nonaktif (disabled)

    @Test("Given belum memilih momen dan ada beberapa momen, When halaman dibuka, Then tombol lanjut nonaktif")
    func trailingButtonDisabledWhenNoMomentSelectedYet() {
        var state = SelectMomentState()
        state.moments = [DummyMoment(id: "1"), DummyMoment(id: "2")]

        #expect(state.selectedMoment == nil)
        #expect(state.canProceed == false)
    }

    // MARK: assertion 2
    // Given belum memilih momen, ada beberapa momen
    // When user memilih salah satu momen
    // Then momen tersebut terpilih, tombol lanjut aktif (enabled)

    @Test("Given ada beberapa momen, When user memilih salah satu, Then momen terpilih dan tombol lanjut aktif")
    func selectingAMomentEnablesTrailingButton() {
        var state = SelectMomentState()
        let momentA = DummyMoment(id: "1")
        let momentB = DummyMoment(id: "2")
        state.moments = [momentA, momentB]

        state.select(momentA)

        #expect(state.selectedMoment?.id == "1")
        #expect(state.canProceed == true)
    }

    // MARK: assertion 3
    // Given tidak ada momen
    // When halaman Select Moment of the Day dibuka
    // Then empty state ditampilkan, tombol lanjut nonaktif

    @Test("Given tidak ada momen sama sekali, When halaman dibuka, Then empty state ditampilkan dan tombol lanjut nonaktif")
    func emptyStateShownAndTrailingButtonDisabledWhenNoMoments() {
        let state = SelectMomentState()

        #expect(state.isEmptyState == true)
        #expect(state.canProceed == false)
    }

    // MARK: assertion 4
    // Given user tekan tombol next untuk lanjut page refleksi
    // When user menekan tombol Lanjut
    // Then halaman berpindah ke pertanyaan refleksi, momen yang dipilih tersimpan

    @Test("Given user sudah memilih momen, When user menekan tombol Lanjut, Then halaman berpindah ke pertanyaan dan momen tersimpan")
    func tappingProceedMovesToQuestionStepAndKeepsSelectedMoment() {
        var state = SelectMomentState()
        let momentA = DummyMoment(id: "1")
        let momentB = DummyMoment(id: "2")
        state.moments = [momentA, momentB]
        state.select(momentB)

        state.proceed()

        #expect(state.step == .question)
        #expect(state.selectedMoment?.id == "2")
    }
}

// MARK: implementasi minimum

enum SelectMomentStep {
    case selectMoment
    case question
}

struct DummyMoment: Identifiable, Equatable {
    let id: String
}

struct SelectMomentState {
    var moments: [DummyMoment] = []
    var selectedMoment: DummyMoment?
    var step: SelectMomentStep = .selectMoment

    var isEmptyState: Bool {
        moments.isEmpty
    }

    var canProceed: Bool {
        selectedMoment != nil
    }

    mutating func select(_ moment: DummyMoment) {
        selectedMoment = moment
    }

    mutating func proceed() {
        guard canProceed else { return }
        step = .question
    }
}
