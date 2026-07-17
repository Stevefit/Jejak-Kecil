import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReviewMomentViewModel {
    var selectedDate: Date = Date()
    var moments: [Moment] = []
    var reflection: Reflection?
    
    private var modelContext: ModelContext?
    private var mockMoments: [Moment] = []
    private var mockReflections: [Reflection] = []
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        if modelContext == nil {
            generateMockData()
        }
        fetchDataForSelectedDate()
    }
    
    func changeDate(to newDate: Date) {
        selectedDate = newDate
        fetchDataForSelectedDate()
    }
    
    func fetchDataForSelectedDate() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        if let context = modelContext {
            let momentPredicate = #Predicate<Moment> { moment in
                moment.timestamp >= startOfDay && moment.timestamp < endOfDay
            }
            let momentFetch = FetchDescriptor<Moment>(predicate: momentPredicate, sortBy: [SortDescriptor(\.timestamp)])
            
            let reflectionPredicate = #Predicate<Reflection> { reflection in
                reflection.date >= startOfDay && reflection.date < endOfDay
            }
            let reflectionFetch = FetchDescriptor<Reflection>(predicate: reflectionPredicate)
            
            do {
                moments = try context.fetch(momentFetch)
                reflection = try context.fetch(reflectionFetch).first
            } catch {
                moments = []
                reflection = nil
            }
        } else {
            moments = mockMoments.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
            reflection = mockReflections.first { $0.date >= startOfDay && $0.date < endOfDay }
        }
    }
    
    private func generateMockData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        guard let placeholderImageData = UIImage(systemName: "photo")?.jpegData(compressionQuality: 0.8) else { return }
        
        let sampleMoment1 = Moment(
            photo: placeholderImageData,
            timestamp: today.addingTimeInterval(36000),
            shortDescription: "Main bikin rumah-rumahan sama Lili."
        )
        let sampleMoment2 = Moment(
            photo: placeholderImageData,
            timestamp: today.addingTimeInterval(50000),
            shortDescription: "Belajar mewarnai gambar pemandangan bersama adik tercinta hari ini."
        )
        
        let choiceQ1 = Choice(type: .b, text: "Anakku yang memulai")
        let questionQ1 = Question(code: "Q1", scope: .daily, answerType: .multipleChoice, text: "Siapa yang memulai momen ini?", displayOrder: 1, choices: [choiceQ1])
        choiceQ1.question = questionQ1
        
        let questionQ4 = Question(code: "Q4", scope: .daily, answerType: .chip, text: "Perasaan apa yang Anda rasakan?", displayOrder: 5)
        let questionQ6 = Question(code: "Q6", scope: .daily, answerType: .essay, text: "Apa yang membuat momen berbeda?", displayOrder: 8)
        
        let answer1 = Answer(question: questionQ1, selectedChoice: choiceQ1)
        let answer4 = Answer(question: questionQ4, selectedChip: "Hangat")
        let answer6 = Answer(question: questionQ6, essayText: "Momen ini terasa hangat dan mengalir.")
        
        let sampleReflection = Reflection(
            date: today.addingTimeInterval(43200),
            moment: sampleMoment1,
            answers: [answer1, answer4, answer6],
            isCompleted: true
        )
        
        sampleMoment1.reflection = sampleReflection
        
        mockMoments = [sampleMoment1, sampleMoment2]
        mockReflections = [sampleReflection]
    }
}
