//
//  DetailRecapMomentViewModel.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 28/07/26.
//

import Foundation
import SwiftData

@Observable
final class DetailRecapMomentViewModel {

    // MARK: - Properties

    let recap: Recap?

    // Rentang minggu: awal minggu sampai sebelum awal minggu berikutnya (upperBound eksklusif).
    // Dipakai View untuk menyusun predicate @Query.
    let weekRange: Range<Date>

    // Lencana yang didapat di minggu ini. Diisi lewat loadBadges(context:).
    private(set) var badges: [BadgeType] = []

    // MARK: - Init

    init(recap: Recap? = nil) {
        self.recap = recap
        self.weekRange = Calendar.current.weekRange(for: recap?.weekStart ?? .now) ?? Date()..<Date()
    }

    // MARK: - Week Info

    private var weekStart: Date { weekRange.lowerBound }

    // upperBound eksklusif, jadi hari terakhir minggu ini mundur satu hari.
    private var weekEnd: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: weekRange.upperBound) ?? weekRange.upperBound
    }

    // Nomor minggu ke berapa dalam bulannya, sama seperti penomoran di arsip.
    var weekNumber: Int {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: weekStart)?.start,
              let firstWeekStart = calendar.weekRange(for: monthStart)?.lowerBound else { return 1 }
        let weeks = calendar.dateComponents([.weekOfYear], from: firstWeekStart, to: weekStart).weekOfYear ?? 0
        return weeks + 1
    }

    var dateRange: String {
        (weekStart..<weekEnd).formatted(
            .interval.day().month(.wide).year().locale(Locale(identifier: "id_ID"))
        )
    }

    // MARK: - Weekly Habit (WQ2)

    // Jawaban essay WQ2, dibaca lewat relasi Recap.essayAnswer — tidak perlu
    // fetch terpisah. Jawaban kosong/spasi diperlakukan sama dengan belum diisi.
    var weeklyHabit: String? {
        guard let text = recap?.essayAnswer?.essayText else { return nil }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Badges

    func loadBadges(context: ModelContext) {
        badges = BadgeService.badges(inWeekStarting: weekRange.lowerBound, context: context)
    }

    // MARK: - Reflections

    // Posisi refleksi yang di-highlight di dalam daftar minggu ini.
    // Daftarnya datang dari @Query milik View, jadi diterima sebagai parameter.
    func highlightedIndex(in reflections: [Reflection]) -> Int? {
        // Recap bisa sudah terhapus (momen sorotannya dihapus) sementara layar ini
        // masih memegang objeknya. Membaca propertinya saat itu akan crash.
        guard let recap, !recap.isDeleted,
              let highlighted = recap.highlightedReflection, !highlighted.isDeleted
        else { return nil }
        return reflections.firstIndex { $0.persistentModelID == highlighted.persistentModelID }
    }
}
