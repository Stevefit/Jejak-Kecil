//
//  RecapQuestionSeeder.swift
//  C03A06
//
//  Seed weekly question (WQ2 essay) untuk weekly recap.
//  WQ1 bukan Question — pilihan Reflection langsung (Recap.highlightedReflection).
//

import Foundation
import SwiftData

enum RecapQuestionSeeder {
    @MainActor
    static func seed(in context: ModelContext) throws {
        // guard by code (String, stored + unique) — aman di predicate.
        // jangan filter by enum scope (Codable enum bisa crash di predicate).
        let descriptor = FetchDescriptor<Question>(
            predicate: #Predicate { $0.code == "WQ2" }
        )
        let existingCount = try context.fetchCount(descriptor)
        guard existingCount == 0 else { return }

        for question in makeSeedQuestions() {
            context.insert(question)
        }
        try context.save()
    }

    static func makeSeedQuestions() -> [Question] {
        // WQ1 (momen berkesan minggu ini) TIDAK di-seed sbg Question.
        // itu pilihan Reflection langsung, disimpan di Recap.highlightedReflection.

        // WQ2 - kebiasaan yang menciptakan momen tsb.
        // opsional ditangani di UI/validasi (essay boleh kosong), spt essay harian.
        let wq2 = Question(
            code: "WQ2",
            scope: .weekly,
            answerType: .essay,
            text: "Apa satu hal yang terus Anda lakukan yang menciptakan momen-momen tersebut?",
            displayOrder: 2
        )

        return [wq2]
    }
}
