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
                .padding(14)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if let category = reflection.moment?.category {
                    Text(category.rawValue)
                        .font(.caption)
                }
                
                Text(reflection.moment?.shortDescription ?? "")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                let q4Answer = reflection.answers.first(where: { $0.question.code == "Q4" })
                let q6Answer = reflection.answers.first(where: { $0.question.code == "Q6" })
                
                if q4Answer?.selectedChip != nil || q6Answer?.essayText != nil {
                    HStack(alignment: .center, spacing: 10) {
                        if let chipText = q4Answer?.selectedChip {
                            Text(chipText)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color.yellow.opacity(0.35))
                                .clipShape(Capsule())
                        }
                        
                        if let q6Text = q6Answer?.essayText, !q6Text.isEmpty {
                            Text(q6Text)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.top, 2)
                }
                
                if let followUpAnswer = reflection.answers.first(where: { $0.question.isFollowUp }),
                   let rawQuote = followUpAnswer.essayText,
                   !rawQuote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    
                    let limitedQuote = String(rawQuote.prefix(120))
                    
                    HStack {
                        Text("“\(limitedQuote)”")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                            .lineSpacing(3)
                            .lineLimit(3)
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
    }
}
