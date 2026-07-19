//
//  ReflectionCard.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 18/07/26.
//


import SwiftUI
import SwiftData

struct ReflectionCard: View {
    let reflection: Reflection
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: reflection.date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // MARK: Image Section
            Group {
                if let moment = reflection.moment, let uiImage = UIImage(data: moment.photo) {
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
            .frame(width: 160, height: 220)
            .cornerRadius(16)
            .clipped()
            
            // MARK: Content Section
            VStack(alignment: .leading, spacing: 8) {
                // Category & Date Header
                Text("\(formattedDate): \(reflection.moment?.category.rawValue ?? "")")
                    .font(.caption2)
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(1)
                
                // Description
                Text(reflection.moment?.shortDescription ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Chip (Q4 - Feeling option)
                if let q4Answer = reflection.answers.first(where: { $0.question.code == "Q4" }),
                   let chipText = q4Answer.selectedChip {
                    Text(chipText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.yellow.opacity(0.4))
                        .clipShape(Capsule())
                }
                
                // Q6 - Essay Option (Moment differences text)
                if let q6Answer = reflection.answers.first(where: { $0.question.code == "Q6" }),
                   let essayText = q6Answer.essayText {
                    Text(essayText)
                        .font(.caption)
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Quote Section (FQ1 or FQ2 follow-ups dynamically if available)
                if let followUpAnswer = reflection.answers.first(where: { $0.question.isFollowUp }),
                   let followUpText = followUpAnswer.essayText {
                    Text("“\(followUpText)”")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(24)
        .padding(.horizontal)
    }
}

#Preview {
    let schema = Schema([
        Item.self,
        Moment.self,
        Reflection.self,
        Answer.self,
        Question.self,
        Choice.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    // 1. Create dummy image data
    let dummyImage = UIImage(systemName: "photo")?.jpegData(compressionQuality: 1.0) ?? Data()
    
    // 2. Instantiate core models
    let moment = Moment(
        photo: dummyImage,
        timestamp: Date(),
        shortDescription: "Main bikin rumah-rumahan sama Lili.",
        category: .bermainBersama
    )
    
    let reflection = Reflection(date: Date(), moment: moment, isCompleted: true)
    
    // 3. Create mock questions and map answers matching the UI layout
    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Perasaan apa?", displayOrder: 5)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Apa perbedaan momen?", displayOrder: 8)
    let fq1 = Question(code: "FQ1", scope: .daily, answerType: .essay, text: "Hal kecil besok?", displayOrder: 2, triggerQuestionCode: "Q1")
    
    let a4 = Answer(question: q4, selectedChip: "Hangat", reflection: reflection)
    let a6 = Answer(question: q6, essayText: "Momen ini terasa hangat dan mengalir.", reflection: reflection)
    let afq1 = Answer(question: fq1, essayText: "Clara yang mulai untuk bermain lego", reflection: reflection)
    
    reflection.answers = [a4, a6, afq1]
    
    // 4. Insert into context to satisfy SwiftData tracking requirements
    container.mainContext.insert(moment)
    container.mainContext.insert(reflection)
    
    return ReflectionCard(reflection: reflection)
        .modelContainer(container)
        .background(Color(.systemGray6))
}
