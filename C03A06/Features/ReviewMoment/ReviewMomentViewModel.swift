import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReviewMomentViewModel {
    var selectedDate: Date = Date()
    var moments: [Moment] = []
    var reflection: Reflection?
    var isShowingReflectionReminderOverlay = false
    // overlay baru bisa ditutup (via tap) setelah jeda, tidak auto-dismiss
    private var canDismissReflectionReminderOverlay = false

    private var weeklyRecapCompleted = false
    private var weeklyHasReflection = false

    // Section refleksi mingguan muncul jika: hari Minggu, ada minimal 1 refleksi minggu ini,
    // dan recap minggu ini belum diisi.
    var shouldShowWeeklyRecap: Bool {
        Calendar.current.component(.weekday, from: selectedDate) == 1  // Minggu (Gregorian)
            && weeklyHasReflection
            && !weeklyRecapCompleted
    }

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

        // status recap & refleksi minggu ini (untuk aturan tampil section refleksi mingguan)
        if let week = calendar.weekRange(for: selectedDate) {
            let weekStart = week.lowerBound
            let weekEnd = week.upperBound

            let recapFetch = FetchDescriptor<Recap>(
                predicate: #Predicate { $0.weekStart == weekStart && $0.isCompleted }
            )
            weeklyRecapCompleted = ((try? context.fetch(recapFetch))?.isEmpty == false)

            let weekReflectionFetch = FetchDescriptor<Reflection>(
                predicate: #Predicate { $0.date >= weekStart && $0.date < weekEnd }
            )
            weeklyHasReflection = ((try? context.fetch(weekReflectionFetch))?.isEmpty == false)
        } else {
            weeklyRecapCompleted = false
            weeklyHasReflection = false
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
        canDismissReflectionReminderOverlay = false

        Task {
            try? await Task.sleep(for: .seconds(2))
            canDismissReflectionReminderOverlay = true
        }
    }

    func dismissReflectionReminderOverlay() {
        guard canDismissReflectionReminderOverlay else { return }
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
