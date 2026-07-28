//
//  BadgeEvaluator.swift
//  C03A06
//
//  Aturan lencana mingguan. Sengaja tanpa ModelContext supaya aturannya
//  terpisah dari mekanika database.
//

import Foundation

enum BadgeEvaluator {

    // MARK: - Konstanta

    // "Refleksi lebih dari lima kali" — lebih dari, bukan minimal.
    static let reflectionRoutineMinimum = 6

    // Senin sampai Minggu.
    static let daysInWeek = 7

    // MARK: - Evaluasi

    /// - Parameters:
    ///   - moments: momen di minggu yang dievaluasi.
    ///   - reflections: refleksi selesai di minggu yang dievaluasi.
    ///   - weekRange: rentang minggu itu, dipakai memetakan momen ke hari.
    ///   - containsFirstMoment: apakah momen paling awal milik user jatuh di minggu ini.
    ///     Ditentukan pemanggil karena butuh data di luar minggu ini.
    static func evaluate(
        moments: [Moment],
        reflections: [Reflection],
        weekRange: Range<Date>,
        containsFirstMoment: Bool
    ) -> Set<BadgeType> {
        var earned: Set<BadgeType> = []
        earned.formUnion(quantityBadges(
            moments: moments,
            reflections: reflections,
            weekRange: weekRange,
            containsFirstMoment: containsFirstMoment
        ))
        earned.formUnion(reflectionBadges(reflections: reflections))
        return earned
    }

    // MARK: - Kategori 3: jumlah/kuantitas

    private static func quantityBadges(
        moments: [Moment],
        reflections: [Reflection],
        weekRange: Range<Date>,
        containsFirstMoment: Bool
    ) -> Set<BadgeType> {
        var earned: Set<BadgeType> = []

        // Melekat pada minggu yang memuat momen paling awal, jadi didapat sekali saja.
        if containsFirstMoment {
            earned.insert(.pemulaMomen)
        }

        // Tiap hari di minggu ini punya minimal satu momen.
        if distinctDays(of: moments, in: weekRange).count == daysInWeek {
            earned.insert(.semingguPenuh)
        }

        if reflections.count >= reflectionRoutineMinimum {
            earned.insert(.refleksiRutin)
        }

        return earned
    }

    // MARK: - Kategori 1: pola refleksi

    // Tanpa ambang minimum: satu refleksi saja sudah bisa memicu lencana di sini.
    private static func reflectionBadges(reflections: [Reflection]) -> Set<BadgeType> {
        var earned: Set<BadgeType> = []

        // Q1: siapa yang memulai momen.
        for winner in modes(of: choices(in: reflections, for: "Q1")) {
            switch winner {
            case .a: earned.insert(.yangSelaluAda)   // "Aku yang memulai"
            case .b: earned.insert(.rumahSiKecil)    // "Anakku yang memulai"
            case .c: break                           // "Orang lain yang memulai"
            }
        }

        // Q2: skala menaik, keterlibatan tertinggi = .c
        if modes(of: choices(in: reflections, for: "Q2")).contains(.c) {
            earned.insert(.hadirPenuh)
        }

        // Q3: skala menurun — .a paling terbuka, .c paling tertutup.
        // .b = "percakapan berlangsung seperti biasa, terbuka, dan santai".
        if modes(of: choices(in: reflections, for: "Q3")).contains(.b) {
            earned.insert(.ruangTerbuka)
        }

        return earned
    }

    // MARK: - Helper

    // Hari-hari berbeda dalam minggu ini yang punya momen. Momen di luar
    // weekRange diabaikan supaya perhitungan tidak bocor ke minggu lain.
    private static func distinctDays(of moments: [Moment], in weekRange: Range<Date>) -> Set<Date> {
        let calendar = Calendar.current
        return Set(
            moments
                .filter { weekRange.contains($0.timestamp) }
                .map { calendar.startOfDay(for: $0.timestamp) }
        )
    }

    // Jawaban pilihan ganda untuk satu kode soal. Refleksi yang tidak menjawab
    // soal itu tidak ikut dihitung sebagai suara.
    private static func choices(in reflections: [Reflection], for code: String) -> [ChoiceType] {
        reflections.compactMap { reflection in
            reflection.answers
                .first { $0.question.code == code }?
                .selectedChoice?
                .type
        }
    }

    // Semua nilai dengan frekuensi tertinggi. Mengembalikan lebih dari satu
    // kalau seri — sesuai aturan "yang seri sama-sama dapat lencana".
    private static func modes<T: Hashable>(of values: [T]) -> [T] {
        guard !values.isEmpty else { return [] }

        let counts = values.reduce(into: [T: Int]()) { $0[$1, default: 0] += 1 }
        guard let highest = counts.values.max() else { return [] }

        return counts.filter { $0.value == highest }.map(\.key)
    }
}
