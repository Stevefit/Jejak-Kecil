//
//  CardCarousel.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 27/07/26.
//

import SwiftUI
import SwiftData

struct CardCarousel: View {
    let reflections: [Reflection]
    var highlightedIndex: Int? = nil

    @State private var index: Int
    @State private var dragWidth: CGFloat = 0

    init(reflections: [Reflection], highlightedIndex: Int? = nil) {
        self.reflections = reflections
        self.highlightedIndex = highlightedIndex
        // Deck dibuka dari kartu yang di-highlight.
        _index = State(initialValue: highlightedIndex ?? 0)
    }

    // Kartu paling depan + maksimal 2 kartu di belakangnya, melingkar dari awal lagi.
    // id-nya pakai posisi refleksi supaya kartu tetap punya identitas saat deck bergeser.
    private var visibleCards: [(reflection: Int, depth: Int)] {
        let count = reflections.count
        guard count > 0 else { return [] }
        return (0..<min(3, count)).map { ((index + $0) % count, $0) }
    }

    var body: some View {
        ZStack {
            ForEach(visibleCards.reversed(), id: \.reflection) { item in
                card(at: item.reflection, depth: item.depth)
            }
        }
        .animation(.spring(duration: 0.3), value: index)
        .overlay {
            HStack {
                arrow("chevron.left", label: "Refleksi sebelumnya") { move(by: -1) }
                Spacer()
                arrow("chevron.right", label: "Refleksi berikutnya") { move(by: 1) }
            }
        }
    }

    private func arrow(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(label, systemImage: systemName, action: action)
            .labelStyle(.iconOnly)
            .font(.title2.weight(.semibold))
            .foregroundStyle(.primary)
            .frame(width: 56, height: 56)
            .background(.background, in: .circle)
            .shadow(color: .black.opacity(0.1), radius: 6, y: 2)
    }

    // Melingkar: lewat kartu terakhir balik ke awal, begitu juga sebaliknya.
    private func move(by step: Int) {
        let count = reflections.count
        guard count > 1 else { return }
        withAnimation(.spring(duration: 0.3)) {
            index = (index + step + count) % count
        }
    }

    private func card(at i: Int, depth rawDepth: Int) -> some View {
        let depth = Double(rawDepth)
        let isTop = rawDepth == 0
        // Kartu belakang dimiringkan bergantian kiri/kanan biar mengintip di samping.
        let tilt: Double = isTop ? dragWidth / 30 : (rawDepth.isMultiple(of: 2) ? 5 : -5)

        return RecapReflectionCard(
            reflection: reflections[i],
            isHighlighted: i == highlightedIndex
        )
        .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
        .scaleEffect(1 - depth * 0.05)
        .offset(x: isTop ? dragWidth : 0, y: depth * 16)
        .rotationEffect(.degrees(tilt), anchor: .bottom)
        .zIndex(-depth)
        .gesture(swipe, including: isTop ? .all : .subviews)
    }

    private var swipe: some Gesture {
        DragGesture()
            .onChanged { dragWidth = $0.translation.width }
            .onEnded { value in
                let width = value.translation.width
                if width < -100 {
                    move(by: 1)
                } else if width > 100 {
                    move(by: -1)
                }
                withAnimation(.spring(duration: 0.3)) { dragWidth = 0 }
            }
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0) ?? Data()

    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Gimana perasaanmu?", displayOrder: 4)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Ada yang mau dicatat?", displayOrder: 6)

    let samples: [(String, MomentCategory, String)] = [
        ("Piknik kecil-kecilan", .pergiBersama, "Dia sempet nangis, tapi tiba-tiba senyum dan ketawain diri sendiri karena mukanya kotor"),
        ("Main bikin rumah-rumahan sama Lili", .bermainBersama, "Dia bilang rumahnya buat kita berdua."),
        ("Masak bareng sore-sore", .berkreasiBersama, "Telurnya gosong tapi dia bangga banget.")
    ]

    let reflections = samples.map { title, category, quote -> Reflection in
        let moment = Moment(photo: dummyImage, timestamp: .now, shortDescription: title, category: category)
        let reflection = Reflection(date: .now, moment: moment, isCompleted: true)
        reflection.answers = [
            Answer(question: q4, selectedChip: Mood.hangat.rawValue, reflection: reflection),
            Answer(question: q6, essayText: quote, reflection: reflection)
        ]
        container.mainContext.insert(moment)
        container.mainContext.insert(reflection)
        return reflection
    }

    return CardCarousel(reflections: reflections, highlightedIndex: 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
        .modelContainer(container)
}
