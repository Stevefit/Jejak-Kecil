import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReviewMomentViewModel {
    var selectedDate: Date = Date()
    var moments: [Moment] = []
    var reflection: Reflection?
    
    func changeDate(to newDate: Date, in context: ModelContext) {
        selectedDate = newDate
        fetchData(in: context)
    }
    
    func fetchData(in context: ModelContext) {
        guard let range = Calendar.current.dayRange(for: selectedDate) else { return }
        let startOfDay = range.lowerBound
        let endOfDay = range.upperBound

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
