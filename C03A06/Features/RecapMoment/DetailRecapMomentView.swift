//
//  DetailRecapMomentView.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 27/07/26.
//

import SwiftUI
import SwiftData

struct DetailRecapMomentView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: DetailRecapMomentViewModel

    // MARK: - Query

    // Refleksi minggu ini, difilter langsung di query (bukan fetch semua lalu saring di memori).
    // @Query harus tinggal di View — property wrapper-nya butuh siklus hidup SwiftUI.
    @Query private var weekReflections: [Reflection]

    // MARK: - Init

    init(recap: Recap? = nil) {
        let viewModel = DetailRecapMomentViewModel(recap: recap)
        _viewModel = State(initialValue: viewModel)

        let start = viewModel.weekRange.lowerBound
        let end = viewModel.weekRange.upperBound
        _weekReflections = Query(
            filter: #Predicate<Reflection> { $0.date >= start && $0.date < end },
            sort: \.date
        )
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Badges

                // Tanpa lencana, seluruh bagian ini disembunyikan — termasuk judulnya.
                if !viewModel.badges.isEmpty {
                    Text("Lencana Minggu Ini")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 20)

                    VStack(spacing: 8) {
                        ForEach(viewModel.badges, id: \.self) { badge in
                            BadgeCardBig(badge: badge)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // MARK: Daily Reflections

                VStack(alignment: .leading) {
                    Text("Refleksi Harian Tercatat (\(weekReflections.count))")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 20)

                    if weekReflections.isEmpty {
                        Text("Belum ada refleksi di minggu ini.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                    } else {
                        CardCarousel(
                            reflections: weekReflections,
                            highlightedIndex: viewModel.highlightedIndex(in: weekReflections)
                        )

                        Text("Geser kartu untuk melihat refleksi lainnya")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                            .padding(.bottom, 20)
                    }
                }

                // MARK: Weekly Habit (WQ2)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Kebiasaan yang Dijaga")
                        .font(.headline.weight(.semibold))

                    Group {
                        if let weeklyHabit = viewModel.weeklyHabit {
                            Text(weeklyHabit)
                                .foregroundStyle(.primary)
                        } else {
                            Text("Belum ada jawaban untuk minggu ini.")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.subheadline)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                    .padding(20)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 22))
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
        .appBackground()
        .task {
            viewModel.loadBadges(context: modelContext)
        }
        .navigationBarTitleDisplayMode(.inline)
        // MARK: Toolbar Title
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Ringkasan Minggu \(viewModel.weekNumber)")
                        .font(.headline.weight(.semibold))
                    Text(viewModel.dateRange)
                        .font(.subheadline.weight(.regular))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self, Recap.self, EarnedBadge.self])
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

    // WQ2: kebiasaan yang dijaga.
    let wq2 = Question(
        code: "WQ2",
        scope: .weekly,
        answerType: .essay,
        text: "Apa satu hal yang terus Anda lakukan yang menciptakan momen-momen tersebut?",
        displayOrder: 2
    )
    context.insert(wq2)
    context.insert(Answer(question: wq2, essayText: "Main bikin rumah-rumahan sama Lili. mencoba sesuatu yaSelalu menyempatkan main bareng sebelum tidur, walau cuma 15 menit", recap: recap))

    // Lencana minggu ini: satu dari tiap kategori, deskripsi terpendek sampai terpanjang.
    for badge in [BadgeType.pemulaMomen, .rumahSiKecil, .semingguPenuh] {
        context.insert(EarnedBadge(type: badge, weekStart: weekStart))
    }

    return NavigationStack {
        DetailRecapMomentView(recap: recap)
    }
    .modelContainer(container)
}
