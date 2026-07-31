//
//  SelectableReflectionCard.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei on 23/07/26.
//

import SwiftUI
import SwiftData

// Card refleksi (foto + deskripsi moment) yang bisa dipilih untuk recap (WQ1).
// Tap di-handle caller (pola SelectableMomentCard), komponen hanya render state.
struct SelectableReflectionCard: View {

    let reflection: Reflection
    var isSelected: Bool = false

    private var moment: Moment? { reflection.moment }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // MARK: foto
            Group {
                if let moment, let uiImage = UIImage(data: moment.photo) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color(.systemGray4)
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 160, height: 160)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // MARK: deskripsi
            Text(moment?.shortDescription ?? "")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 48, maxHeight: 48, alignment: .topLeading)
                .padding(.horizontal, 4)
        }
        .padding(6)
        .frame(width: 172, height: 234, alignment: .top)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isSelected ? 1.0 : 0.5)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isSelected ? .blue : .clear,
                    lineWidth: 3
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0) ?? Data()

    let moment = Moment(
        photo: dummyImage,
        timestamp: .now,
        shortDescription: "12345 123 123 123 123 123 123 123 123 123 123 13 13 12",
        category: .bermainBersama
    )
    let reflection = Reflection(date: .now, moment: moment, isCompleted: true)

    // reflection tanpa moment (fallback)
    let empty = Reflection(date: .now, moment: nil, isCompleted: false)

    container.mainContext.insert(moment)
    container.mainContext.insert(reflection)
    container.mainContext.insert(empty)

    return VStack(spacing: 12) {
        SelectableReflectionCard(reflection: reflection, isSelected: true)
        SelectableReflectionCard(reflection: reflection, isSelected: false)
        SelectableReflectionCard(reflection: empty, isSelected: false)
    }
    .padding()
    .frame(width: 600)
    .background(Color(.systemGray6))
    .modelContainer(container)
}
