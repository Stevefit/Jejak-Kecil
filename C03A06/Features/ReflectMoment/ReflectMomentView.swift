//
//  ReflectMomentView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import SwiftUI
import UIKit
import SwiftData

struct ReflectMomentView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ReflectMomentViewModel
    let onClose: () -> Void

    init(date: Date = .now, onClose: @escaping () -> Void) {
        _viewModel = State(initialValue: ReflectMomentViewModel(date: date))
        self.onClose = onClose
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            Spacer()

            if viewModel.isEmptyState {
                emptyStateView
            } else {
                momentPickerView
            }

            Spacer()
        }
        .padding()
        .task {
            viewModel.loadMoments(context: modelContext)
        }
    }

    // MARK: header

    private var header: some View {
        NavigationHeaderBar(
            title: "Refleksi Hari ini",
            leadingIcon: "xmark",
            onLeadingTap: onClose,
            trailingIcon: "chevron.right",
            isTrailingEnabled: viewModel.canProceedFromMomentSelection,
            onTrailingTap: { viewModel.proceedToQuestions() },
            progressCurrent: 1,
            progressTotal: 5
        )
    }

    // MARK: TEC-211: show all moments logged that day (carousel)

    private var momentPickerView: some View {
        VStack(spacing: 28) {

            VStack(spacing: 6) {
                Text("Pilih Momen Hari Ini")
                    .font(.title3.weight(.semibold))

                Text("Momen mana yang mau diceritakan?")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            momentCarousel
        }
    }

    // carousel horizontal, kartu di tengah otomatis lebih besar
    private var momentCarousel: some View {
        let cardWidth: CGFloat = 210
        let cardHeight: CGFloat = 300
        let spacing: CGFloat = 28

        return GeometryReader { geometry in
            let sideInset = (geometry.size.width - cardWidth) / 2

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(viewModel.moments, id: \.persistentModelID) { moment in
                        SelectableMomentCard(
                            moment: moment,
                            isSelected: viewModel.selectedMoment?.persistentModelID == moment.persistentModelID
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                        .scrollTransition(axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                .opacity(phase.isIdentity ? 1 : 0.6)
                        }
                        .onTapGesture {
                            viewModel.select(moment)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sideInset)
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(height: cardHeight)
    }

    // MARK: TEC-213: empty state

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Belum ada momen yang tercatat hari ini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: preview helper: bikin data foto dummy

private func dummyPhotoData(color: UIColor) -> Data {
    let size = CGSize(width: 300, height: 420)
    let renderer = UIGraphicsImageRenderer(size: size)
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
    }
    return image.pngData() ?? Data()
}

// MARK: preview TEC-211, carousel dengan beberapa moment

#Preview("TEC-211: Carousel Beberapa Momen") {
    let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let moments = [
        Moment(photo: dummyPhotoData(color: .systemOrange), timestamp: .now, shortDescription: "Bermain di taman", category: .bermainBersama),
        Moment(photo: dummyPhotoData(color: .systemTeal), timestamp: .now, shortDescription: "Ngobrol sebelum tidur", category: .ngobrolDanCerita),
        Moment(photo: dummyPhotoData(color: .systemPurple), timestamp: .now, shortDescription: "Belajar bersama", category: .belajarDanEksplorasi),
        Moment(photo: dummyPhotoData(color: .systemPink), timestamp: .now, shortDescription: "Masak bareng", category: .berkreasiBersama)
    ]
    moments.forEach { container.mainContext.insert($0) }
    try? container.mainContext.save()

    return Color(.systemGray5)
        .sheet(isPresented: .constant(true)) {
            ReflectMomentView(onClose: {})
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .modelContainer(container)
}

// MARK: preview TEC-213, empty state

#Preview("TEC-213: Empty State") {
    let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    return ReflectMomentView(onClose: {})
        .modelContainer(container)
}
