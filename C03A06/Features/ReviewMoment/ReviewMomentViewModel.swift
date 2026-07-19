import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReviewMomentViewModel {
    var selectedDate: Date = Date()
    var moments: [Moment] = []
    var reflection: Reflection?
    
    var modelContext: ModelContext?
    
    func changeDate(to newDate: Date) {
        selectedDate = newDate
        fetchData()
    }
    
    func fetchData() {
        guard let context = modelContext else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        let momentPredicate = #Predicate<Moment> { moment in
            moment.timestamp >= startOfDay && moment.timestamp < endOfDay
        }
        let momentFetch = FetchDescriptor<Moment>(
            predicate: momentPredicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        let reflectionPredicate = #Predicate<Reflection> { reflection in
            reflection.date >= startOfDay && reflection.date < endOfDay
        }
        let reflectionFetch = FetchDescriptor<Reflection>(predicate: reflectionPredicate)
        
        do {
            self.moments = try context.fetch(momentFetch)
            self.reflection = try context.fetch(reflectionFetch).first
        } catch {
            print("SwiftData Fetch Error: \(error.localizedDescription)")
            self.moments = []
            self.reflection = nil
        }
    }
}
