import SwiftUI
import SwiftData

struct ReflectionCard: View {
    let reflection: Reflection
    var onEdit: (() -> Void)? = nil
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: reflection.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                .cornerRadius(16)
                // FIX BUG: Lock touch area to card frame
                .contentShape(Rectangle())

                Button(action: {
                    onEdit?()
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(14)
            }
            
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
                
                if let chipText = q4Answer?.selectedChip {
                    HStack(alignment: .center, spacing: 10) {
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
                                .lineLimit(6)
                        }
                    }
                }
                
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
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
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
        shortDescription: "Main bikin rumah-rumahan sama Lili. mencoba sesuatu ya",
        category: .bermainBersama
    )
    let reflection = Reflection(date: .now, moment: moment, isCompleted: true)

    let q4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Gimana perasaanmu?", displayOrder: 4)
    let q6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Ada yang mau dicatat?", displayOrder: 6)

    reflection.answers = [
        Answer(question: q4, selectedChip: Mood.hangat.rawValue, reflection: reflection),
        Answer(question: q6, essayText: "Dia bilang rumahnya buat kita berdua. Dia bilang rumahnya buat kita berdua. SELESAI.", reflection: reflection)
    ]

    // reflection tanpa moment & tanpa jawaban (fallback)
    let empty = Reflection(date: .now, moment: nil, isCompleted: false)

    container.mainContext.insert(moment)
    container.mainContext.insert(reflection)
    container.mainContext.insert(empty)

    return ScrollView {
        VStack(spacing: 16) {
            ReflectionCard(reflection: reflection, onEdit: { print("edit") })
            ReflectionCard(reflection: empty)
        }
        .padding(.vertical)
    }
    .background(Color(.systemGray6))
    .modelContainer(container)
}
