//
//  ReflectMomentView.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import SwiftUI
import UIKit

struct ReflectMomentView: View {

    @State private var selectedMomentID: UUID?

    let items: [MomentItem]
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            header

            Spacer()

            if items.isEmpty {
                emptyStateView
            } else {
                momentPickerView
            }

            Spacer()
        }
        .padding()
    }

    // MARK: header

    private var header: some View {
        NavigationHeaderBar(
            title: "Refleksi Hari ini",
            leadingIcon: "xmark",
            onLeadingTap: onClose,
            trailingIcon: "chevron.right",
            isTrailingEnabled: selectedMomentID != nil,
            onTrailingTap: {},
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
                    ForEach(items) { item in
                        MomentCard(
                            moment: item.moment,
                            isSelected: selectedMomentID == item.id
                        )
                        .frame(width: cardWidth, height: cardHeight)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(phase.isIdentity ? 1.0 : 0.9)
                                .opacity(phase.isIdentity ? 1 : 0.6)
                        }
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.25)) {
                                selectedMomentID = item.id
                            }
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sideInset)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedMomentID)
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

// MARK: wrapper item untuk carousel (id stabil untuk ForEach/seleksi)

struct MomentItem: Identifiable {
    let id: UUID
    let moment: Moment

    init(id: UUID = UUID(), moment: Moment) {
        self.id = id
        self.moment = moment
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
    Color(.systemGray5)
        .sheet(isPresented: .constant(true)) {
            ReflectMomentView(
                items: [
                    MomentItem(moment: Moment(photo: dummyPhotoData(color: .systemOrange), timestamp: .now, shortDescription: "Bermain di taman", category: .bermainBersama)),
                    MomentItem(moment: Moment(photo: dummyPhotoData(color: .systemTeal), timestamp: .now, shortDescription: "Ngobrol sebelum tidur", category: .ngobrolDanCerita)),
                    MomentItem(moment: Moment(photo: dummyPhotoData(color: .systemPurple), timestamp: .now, shortDescription: "Belajar bersama", category: .belajarDanEksplorasi)),
                    MomentItem(moment: Moment(photo: dummyPhotoData(color: .systemPink), timestamp: .now, shortDescription: "Masak bareng", category: .berkreasiBersama))
                ],
                onClose: {}
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
}

// MARK: preview TEC-212, hanya satu moment

#Preview("TEC-212: Satu Momen") {
    ReflectMomentView(
        items: [
            MomentItem(moment: Moment(photo: dummyPhotoData(color: .systemOrange), timestamp: .now, shortDescription: "Bermain di taman", category: .bermainBersama))
        ],
        onClose: {}
    )
}

// MARK: preview: TEC-213, empty state

#Preview("TEC-213: Empty State") {
    ReflectMomentView(
        items: [],
        onClose: {}
    )
}
