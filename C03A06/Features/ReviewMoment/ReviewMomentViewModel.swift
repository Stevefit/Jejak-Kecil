import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReviewMomentViewModel {
    var selectedDate: Date = Date()
    var moments: [Moment] = []
    var reflection: Reflection?
    var isShowingReflectionReminderOverlay = false
    
    var modelContext: ModelContext?
    private let reflectionReminderOverlayDateKey = "lastReflectionReminderOverlayDate"
    
    func changeDate(to newDate: Date) {
        selectedDate = newDate
        fetchData()
    }
    
    func fetchData() {
        guard let context = modelContext else {
            self.moments = []
            self.reflection = nil
            return
        }
        
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
    
    func updateMoment(_ moment: Moment, withDescription description: String, date: Date, photoData: Data?) {
        guard let context = modelContext else { return }
        
        moment.shortDescription = description
        moment.timestamp = date
        if let photoData {
            moment.photo = photoData
        }
        
        try? context.save()
        fetchData()
    }

    func deleteMoment(_ moment: Moment) {
        guard let context = modelContext else { return }
        context.delete(moment)
        try? context.save()
        fetchData()
    }

    func showReflectionReminderOverlayIfNeeded() {
        guard Calendar.current.isDateInToday(selectedDate), reflection == nil else {
            isShowingReflectionReminderOverlay = false
            return
        }

        let todayKey = Self.reflectionReminderDateFormatter.string(from: Date())
        guard UserDefaults.standard.string(forKey: reflectionReminderOverlayDateKey) != todayKey else { return }

        UserDefaults.standard.set(todayKey, forKey: reflectionReminderOverlayDateKey)
        isShowingReflectionReminderOverlay = true

        Task {
            try? await Task.sleep(for: .seconds(3))
            dismissReflectionReminderOverlay()
        }
    }

    func dismissReflectionReminderOverlay() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowingReflectionReminderOverlay = false
        }
    }

    private static let reflectionReminderDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
