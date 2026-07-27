//
//  DetailRecapMomentView.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 27/07/26.
//

import SwiftUI
import SwiftData

struct DetailRecapMomentView: View {
    var recap: Recap? = nil

    // Refleksi minggu ini, difilter langsung di query (bukan fetch semua lalu saring di memori).
    @Query private var weekReflections: [Reflection]

    private let weekStart: Date
    private let weekEnd: Date

    init(recap: Recap? = nil) {
        self.recap = recap

        let calendar = Calendar.current
        let range = calendar.weekRange(for: recap?.weekStart ?? .now) ?? Date()..<Date()
        weekStart = range.lowerBound
        weekEnd = calendar.date(byAdding: .day, value: -1, to: range.upperBound) ?? range.upperBound

        let start = range.lowerBound
        let end = range.upperBound
        _weekReflections = Query(
            filter: #Predicate<Reflection> { $0.date >= start && $0.date < end },
            sort: \.date
        )
    }

    // Nomor minggu ke berapa dalam bulannya, sama seperti penomoran di arsip.
    private var weekNumber: Int {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: weekStart)?.start,
              let firstWeekStart = calendar.weekRange(for: monthStart)?.lowerBound else { return 1 }
        let weeks = calendar.dateComponents([.weekOfYear], from: firstWeekStart, to: weekStart).weekOfYear ?? 0
        return weeks + 1
    }

    private var dateRange: String {
        (weekStart..<weekEnd).formatted(
            .interval.day().month(.wide).year().locale(Locale(identifier: "id_ID"))
        )
    }

    private var highlightedIndex: Int? {
        guard let highlighted = recap?.highlightedReflection else { return nil }
        return weekReflections.firstIndex { $0.persistentModelID == highlighted.persistentModelID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Lencana Minggu Ini")
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 16)

                // Lencana masih statis, belum di-fetch.
                VStack(spacing: 8) {
                    BadgeCardBig()
                    BadgeCardBig()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Refleksi Harian Tercatat (\(weekReflections.count))")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 16)

                    if weekReflections.isEmpty {
                        Text("Belum ada refleksi di minggu ini.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    } else {
                        CardCarousel(
                            reflections: weekReflections,
                            highlightedIndex: highlightedIndex
                        )

                        Text("Geser kartu untuk melihat refleksi lainnya")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Ringkasan Minggu \(weekNumber)")
                        .font(.headline)
                    Text(dateRange)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0) ?? Data()
    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Gimana perasaanmu?", displayOrder: 4)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Ada yang mau dicatat?", displayOrder: 6)

    let samples: [(String, MomentCategory, String)] = [
        ("Main bikin rumah-rumahan sama Lili", .bermainBersama, "Clara yang mulai untuk bermain lego"),
        ("Piknik kecil-kecilan", .pergiBersama, "Dia sempet nangis, tapi tiba-tiba senyum sendiri"),
        ("Masak bareng sore-sore", .berkreasiBersama, "Telurnya gosong tapi dia bangga banget.")
    ]

    let reflections = samples.enumerated().map { offset, sample -> Reflection in
        let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
        let moment = Moment(photo: dummyImage, timestamp: date, shortDescription: sample.0, category: sample.1)
        let reflection = Reflection(date: date, moment: moment, isCompleted: true)
        reflection.answers = [
            Answer(question: q4, selectedChip: Mood.hangat.rawValue, reflection: reflection),
            Answer(question: q6, essayText: sample.2, reflection: reflection)
        ]
        context.insert(moment)
        context.insert(reflection)
        return reflection
    }

    let weekStart = Calendar.current.weekRange(for: .now)?.lowerBound ?? .now
    let recap = Recap(weekStart: weekStart, highlightedReflection: reflections.first, isCompleted: true)
    context.insert(recap)

    return NavigationStack {
        DetailRecapMomentView(recap: recap)
    }
    .modelContainer(container)
}
