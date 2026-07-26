import SwiftUI
import SwiftData

@MainActor
@Observable
final class CalendarHistoryViewModel {
    var selectedTab: Int
    var selectedDate: Date = Date() {
        didSet {
            filterSelectedDayData()
        }
    }
    
    var showingDatePicker = false
    var showingCreateMoment = false
    var showingReflectMoment = false

    private(set) var monthMoments: [Moment] = []
    private(set) var monthReflections: [Reflection] = []
    private(set) var selectedDayMoments: [Moment] = []
    private(set) var selectedDayReflection: Reflection? = nil
    
    private(set) var imageCacheByDay: [Date: Data] = [:]
    private(set) var datesWithReflection: Set<Date> = []

    private let calendar: Calendar
    private var modelContext: ModelContext?

    // Menerima initialTab (0 untuk Mingguan, 1 untuk Harian) agar
    // halaman pemanggil bisa menentukan tab apa yang pertama kali terbuka.
    init(calendar: Calendar = .current, initialTab: Int = 1) {
        self.calendar = calendar
        self.selectedTab = initialTab
    }

    var formattedMonthYear: String {
        selectedDate.formatted(
            .dateTime
                .month(.wide)
                .year()
                .locale(Locale(identifier: "id_ID"))
        )
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchDataForMonth()
    }

    func fetchDataForMonth() {
        guard let context = modelContext,
              let monthRange = calendar.dateInterval(of: .month, for: selectedDate) else { return }

        let startOfMonth = monthRange.start
        let endOfMonth = monthRange.end

        let momentPredicate = #Predicate<Moment> { moment in
            moment.timestamp >= startOfMonth && moment.timestamp < endOfMonth
        }
        let momentFetch = FetchDescriptor<Moment>(
            predicate: momentPredicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )

        let reflectionPredicate = #Predicate<Reflection> { reflection in
            reflection.date >= startOfMonth && reflection.date < endOfMonth
        }
        let reflectionFetch = FetchDescriptor<Reflection>(predicate: reflectionPredicate)

        do {
            self.monthMoments = try context.fetch(momentFetch)
            self.monthReflections = try context.fetch(reflectionFetch)
            
            buildCaches()
            filterSelectedDayData()
        } catch {
            print("Failed to fetch month data: \(error)")
            self.monthMoments = []
            self.monthReflections = []
            self.imageCacheByDay = [:]
            self.datesWithReflection = []
        }
    }

    private func buildCaches() {
        var imgCache: [Date: Data] = [:]
        var refDates: Set<Date> = []
        
        for reflection in monthReflections {
            let startDay = calendar.startOfDay(for: reflection.date)
            refDates.insert(startDay)
            if let photoData = reflection.moment?.photo {
                imgCache[startDay] = photoData
            }
        }
        
        for moment in monthMoments {
            let startDay = calendar.startOfDay(for: moment.timestamp)
            if imgCache[startDay] == nil {
                imgCache[startDay] = moment.photo
            }
        }
        
        self.imageCacheByDay = imgCache
        self.datesWithReflection = refDates
    }

    func filterSelectedDayData() {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        selectedDayMoments = monthMoments.filter { $0.timestamp >= startOfDay && $0.timestamp < endOfDay }
        selectedDayReflection = monthReflections.first { $0.date >= startOfDay && $0.date < endOfDay }
    }

    func getDayImage(for date: Date) -> Data? {
        imageCacheByDay[calendar.startOfDay(for: date)]
    }

    func hasReflection(for date: Date) -> Bool {
        datesWithReflection.contains(calendar.startOfDay(for: date))
    }

    func daysForMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var dates: [Date?] = []
        var currentDate = monthFirstWeek.start

        while currentDate < monthInterval.end || calendar.component(.weekday, from: currentDate) != 1 {
            if calendar.isDate(currentDate, equalTo: selectedDate, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }

        return dates
    }
}
