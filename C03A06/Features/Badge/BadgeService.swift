//
//  BadgeService.swift
//  C03A06
//
//  Menghitung ulang lencana satu minggu lalu menyelaraskannya dengan database.
//

import Foundation
import SwiftData

@MainActor
struct BadgeService {

    let modelContext: ModelContext

    // MARK: - Sinkronisasi

    // Dipanggil tiap ada perubahan momen atau refleksi. Lencana minggu berjalan
    // boleh berubah, jadi ini menambah yang baru memenuhi syarat DAN mencabut
    // yang tidak lagi memenuhi.
    func evaluateAndSync(weekOf date: Date) {
        guard let week = Calendar.current.weekRange(for: date) else {
            print("[BadgeService] evaluateAndSync error: weekRange nil untuk date \(date)")
            return
        }

        let start = week.lowerBound
        let end = week.upperBound

        let momentFetch = FetchDescriptor<Moment>(
            predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end }
        )
        let reflectionFetch = FetchDescriptor<Reflection>(
            predicate: #Predicate { $0.date >= start && $0.date < end && $0.isCompleted }
        )
        let existingFetch = FetchDescriptor<EarnedBadge>(
            predicate: #Predicate { $0.weekStart == start }
        )

        do {
            let moments = try modelContext.fetch(momentFetch)
            let reflections = try modelContext.fetch(reflectionFetch)
            let existing = try modelContext.fetch(existingFetch)

            // Pemula Momen dipatok sekali seumur pemakaian. Tidak dihitung dari
            // momen bertanggal paling awal — momen bisa dibuat dengan tanggal
            // lampau lewat Arsip, dan itu tidak boleh memindahkan lencananya ke
            // minggu lampau tersebut. Jadi: diberikan ke minggu pertama yang
            // punya momen saat dievaluasi, lalu dibiarkan di sana.
            let containsFirstMoment = try !moments.isEmpty && !hasFirstMomentBadge()

            let deserved = BadgeEvaluator.evaluate(
                moments: moments,
                reflections: reflections,
                weekRange: week,
                containsFirstMoment: containsFirstMoment
            )
            let alreadyStored = Set(existing.compactMap(\.type))

            // Cabut yang tidak lagi memenuhi syarat (termasuk baris rusak yang
            // rawType-nya tidak dikenali lagi). Pemula Momen dikecualikan: sudah
            // didapat berarti tetap milik minggu itu.
            for badge in existing where badge.type.map({ $0 != .pemulaMomen && !deserved.contains($0) }) ?? true {
                modelContext.delete(badge)
            }

            // Tambah yang baru didapat.
            for type in deserved.subtracting(alreadyStored) {
                modelContext.insert(EarnedBadge(type: type, weekStart: start))
            }

            // Data lama bisa punya lebih dari satu Pemula Momen dari aturan
            // sebelumnya, jadi dirapikan di sini.
            try keepOnlyEarliestFirstMomentBadge()

            try modelContext.save()
        } catch {
            print("[BadgeService] evaluateAndSync error: \(error)")
        }
    }

    private static func firstMomentBadgeDescriptor() -> FetchDescriptor<EarnedBadge> {
        let rawType = BadgeType.pemulaMomen.rawValue
        return FetchDescriptor<EarnedBadge>(
            predicate: #Predicate { $0.rawType == rawType },
            sortBy: [SortDescriptor(\.earnedAt, order: .forward)]
        )
    }

    private func hasFirstMomentBadge() throws -> Bool {
        try modelContext.fetchCount(Self.firstMomentBadgeDescriptor()) > 0
    }

    // Yang paling dulu didapat dipertahankan, salinan berikutnya dibuang.
    private func keepOnlyEarliestFirstMomentBadge() throws {
        for badge in try modelContext.fetch(Self.firstMomentBadgeDescriptor()).dropFirst() {
            modelContext.delete(badge)
        }
    }

    // Untuk perubahan yang bisa memindahkan momen antar minggu.
    func evaluateAndSync(weeksOf dates: [Date]) {
        let calendar = Calendar.current
        let weekStarts = Set(dates.compactMap { calendar.weekRange(for: $0)?.lowerBound })
        for weekStart in weekStarts {
            evaluateAndSync(weekOf: weekStart)
        }
    }

    // MARK: - Pembacaan

    static func badges(inWeekStarting weekStart: Date, context: ModelContext) -> [BadgeType] {
        let descriptor = FetchDescriptor<EarnedBadge>(
            predicate: #Predicate { $0.weekStart == weekStart },
            sortBy: [SortDescriptor(\.earnedAt, order: .forward)]
        )

        do {
            return try context.fetch(descriptor).compactMap(\.type)
        } catch {
            print("[BadgeService] badges(inWeekStarting:) error: \(error)")
            return []
        }
    }

    // Berapa minggu tiap lencana pernah didapat, untuk daftar lencana di Profil.
    static func earnedCounts(context: ModelContext) -> [BadgeType: Int] {
        do {
            let all = try context.fetch(FetchDescriptor<EarnedBadge>())
            return all.compactMap(\.type).reduce(into: [:]) { $0[$1, default: 0] += 1 }
        } catch {
            print("[BadgeService] earnedCounts error: \(error)")
            return [:]
        }
    }
}
