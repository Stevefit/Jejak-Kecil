//
//  RecapReflectionCard.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 27/07/26.
//

import SwiftUI
import SwiftData

struct RecapReflectionCard: View {

    // MARK: - Properties

    let reflection: Reflection
    var isHighlighted: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: Photo

            ZStack(alignment: .bottomTrailing) {
                GeometryReader { geometry in
                    Group {
                        if let moment = reflection.moment, let uiImage = UIImage(data: moment.photo) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                        } else {
                            ZStack {
                                Color(.systemGray4)
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                }
                .frame(height: 320)
                .cornerRadius(12)
            }
            // MARK: Highlight Ribbon
            .overlay(alignment: .topLeading) {
                if isHighlighted {
                    Text("Momen Paling Berkesan")
                        .font(.subheadline.weight(.bold).italic())
                        .foregroundColor(.white)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 5)
                        .background(Color.accentColor, in: RibbonShape())
                        .offset(x: -7, y: 14)
                }
            }
            
            // MARK: Text Content

            VStack(alignment: .leading, spacing: 12) {
                if let category = reflection.moment?.category {
                    Text(category.rawValue)
                        .font(.caption2)
                }
                
                Text(reflection.moment?.shortDescription ?? "")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                let q4Answer = reflection.answers.first(where: { $0.question.code == "Q4" })
                let q6Answer = reflection.answers.first(where: { $0.question.code == "Q6" })
                
                // MARK: Mood Chip (Q4)

                if let chipText = q4Answer?.selectedChip {
                    HStack(alignment: .center, spacing: 16) {
                        Text(chipText)
                            .font(.caption2)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.yellow.opacity(0.35))
                            .clipShape(Capsule())
                        
                        if let mood = Mood(rawValue: chipText) {
                            Text(mood.reflectionDescription)
                                .font(.caption2.weight(.semibold))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        }
                    }
                }
                
                // MARK: Quote (Q6)

                if let rawQuote = q6Answer?.essayText,
                   !rawQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    
                    let limitedQuote = String(rawQuote.prefix(120))
                    
                    HStack {
                        Text("“\(limitedQuote)”")
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(.primary)
                            .lineSpacing(3)
                            .lineLimit(3, reservesSpace: true)
                            .multilineTextAlignment(.leading)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6).opacity(0.7))
                    .cornerRadius(16)
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
        .padding(7)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if isHighlighted {
                LinearGradient(
                    colors: [Color(red: 0.75, green: 0.76, blue: 0.97), .white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                Color.white
            }
        }
        .cornerRadius(12)
        .contentShape(Rectangle())
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 40)
    }
}

// MARK: - RibbonShape

// Banner with a V-notch cut into its trailing edge.
private struct RibbonShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX - 16, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: 0, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([Moment.self, Reflection.self, Answer.self, Question.self, Choice.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0) ?? Data()

    let moment = Moment(
        photo: dummyImage,
        timestamp: .now,
        shortDescription: "Main bikin rumah-rumahan sama Lili. mencoba sesuatu ya",
        category: .bermainBersama
    )
    let reflection = Reflection(date: .now, moment: moment, isCompleted: true)

    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Gimana perasaanmu?", displayOrder: 4)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Ada yang mau dicatat?", displayOrder: 6)

    reflection.answers = [
        Answer(question: q4, selectedChip: Mood.hangat.rawValue, reflection: reflection),
        Answer(question: q6, essayText: "Dia bilang rumahnya buat kita berdua.Dia bilang rumahnya buat kita berdua.Dia bilang rumahnya buat kita berdua. SELESAI. ", reflection: reflection)
    ]

    // reflection tanpa moment & tanpa jawaban (fallback)
    let empty = Reflection(date: .now, moment: nil, isCompleted: false)

    container.mainContext.insert(moment)
    container.mainContext.insert(reflection)
    container.mainContext.insert(empty)

    return ScrollView {
        VStack(spacing: 16) {
            RecapReflectionCard(reflection: reflection, isHighlighted: true)
            RecapReflectionCard(reflection: reflection)
            RecapReflectionCard(reflection: empty)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGray6))
    .modelContainer(container)
}
