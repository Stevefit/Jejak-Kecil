//
//  RecapMomentViewModel.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 21/07/26.
//

import Foundation
import SwiftData

@Observable
final class RecapMomentViewModel {
    
    static let essayMaxLength = 120
    
    // MARK: WQ1: pilihan reflection minggu ini
    private(set) var weeklyReflections: [Reflection] = []
    var selectedReflection: Reflection?
    
    // MARK: WQ2: jawaban essay
    var essayText: String = ""
    private(set) var wq2Question: Question?
    
    private let date: Date
    private let weekStart: Date
    private let modelContext: ModelContext

    init(modelContext: ModelContext, date: Date = .now) {
        self.modelContext = modelContext
        self.date = date
        self.weekStart = Calendar.current.weekRange(for: date)?.lowerBound ?? Calendar.current.startOfDay(for: date) // ambil lowerbound (tanggal awal dari range)
    }

    // MARK: load reflection minggu ini (untuk pilihan WQ1)
    
    func loadWeeklyReflections() {
        guard let range = Calendar.current.weekRange(for: date) else {
            print("[RecapMomentViewModel] loadWeeklyReflections error: gagal mendapatkan weekRange untuk date \(date)")
            weeklyReflections = []
            return
        }
        let start = range.lowerBound
        let end = range.upperBound
        
        // fetch dgn 'query'
        // Ambil semua Reflection mulai awal minggu sampai sebelum awal minggu berikutnya.
        let descriptor = FetchDescriptor<Reflection>(
            predicate: #Predicate { reflection in
                reflection.date >= start && reflection.date < end
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        
        do {
            weeklyReflections = try modelContext.fetch(descriptor)
        } catch {
            print("[RecapMomentViewModel] loadWeeklyReflections error: fetch Reflection gagal - \(error)")
            weeklyReflections = []
        }
    }
    
    func select(_ reflection: Reflection) {
        selectedReflection = reflection
    }
    
    // MARK: load WQ2
    
    func seedQuestionsIfNeeded() {
        do {
            try RecapQuestionSeeder.seed(in: modelContext)
        } catch {
            print("[RecapMomentViewModel] seedQuestionsIfNeeded error: RecapQuestionSeeder.seed gagal - \(error)")
        }
    }
    
    func loadWQ2() {
        let descriptor = FetchDescriptor<Question>(
            predicate: #Predicate { $0.code == "WQ2" }
        )
        
        do {
            wq2Question = try modelContext.fetch(descriptor).first
        } catch {
            print("[RecapMomentViewModel] loadWQ2 error: fetch Question gagal - \(error)")
            wq2Question = nil
        }
    }
    
    // MARK: validasi
    
    var isReflectionSelected: Bool {
        selectedReflection != nil
    }
    
    var isEssayValid: Bool {
        let trimmed = essayText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && essayText.count <= Self.essayMaxLength //string tidak kosong , dan tidak lebih dari maxlength
    }
    
    var canSave: Bool {
        isReflectionSelected && isEssayValid
    }
    
    // MARK: simpan recap ke database
    func saveRecap() -> Bool {
        guard canSave,
              let highlightedReflection = selectedReflection,
              let question = wq2Question
        else {
            print("[RecapMomentViewModel] saveRecap error: validasi gagal (reflection minggu ini belum dipilih, WQ2 kosong/lebih dari \(Self.essayMaxLength) char, atau soal WQ2 belum dimuat)")
            return false
        }
        
        let recap = Recap(weekStart: weekStart, highlightedReflection: highlightedReflection, isCompleted: true)
        modelContext.insert(recap)
        
        let answer = Answer(question: question, essayText: essayText, recap: recap)
        modelContext.insert(answer)
        
        do {
            try modelContext.save()
            return true
        } catch {
            print("[RecapMomentViewModel] saveRecap error: modelContext.save() gagal - \(error)")
            return false
        }
    }
}
