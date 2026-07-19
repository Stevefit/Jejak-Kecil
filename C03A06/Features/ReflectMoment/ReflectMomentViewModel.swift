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

@Observable
final class ReflectMomentViewModel {

    // MARK: step/navigation state

    private(set) var step: ReflectStep = .selectMoment

    // MARK: TEC-210: moment selection state

    private(set) var moments: [Moment] = []
    var selectedMoment: Moment?
    private(set) var isLoadingMoments: Bool = false

    private let date: Date

    init(date: Date = .now) {
        self.date = date
    }

    // MARK: TEC-211: show all moments logged that day
    // modelContext diterima dari View (yang mengambilnya dari @Environment),
    // bukan disimpan lewat init.

    func loadMoments(context: ModelContext) {
        isLoadingMoments = true
        defer { isLoadingMoments = false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            moments = []
            return
        }

        let descriptor = FetchDescriptor<Moment>(
            predicate: #Predicate { moment in
                moment.timestamp >= startOfDay && moment.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )

        do {
            moments = try context.fetch(descriptor)
        } catch {
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

    // MARK: transisi selectMoment ke question

    func proceedToQuestions() {
        guard canProceedFromMomentSelection else { return }
        step = .question
    }
}
