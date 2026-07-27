import SwiftUI
import SwiftData

@MainActor
@Observable
final class CalendarHistoryViewModel {
    
    struct WeeklyArchiveItem: Identifiable {
        let id = UUID()
        let weekNumber: Int
        let startDate: Date
        let endDate: Date
        let dateRangeString: String
        let recap: Recap?
        let totalReflections: Int
    }

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
    
    private(set) var weeklyArchiveItems: [WeeklyArchiveItem] = []

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
            buildWeeklyArchiveItems()
        } catch {
            print("Failed to fetch month data: \(error)")
            self.monthMoments = []
            self.monthReflections = []
            self.imageCacheByDay = [:]
            self.datesWithReflection = []
            self.weeklyArchiveItems = []
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

    private func buildWeeklyArchiveItems() {
        guard let context = modelContext,
              let monthRange = calendar.dateInterval(of: .month, for: selectedDate) else { return }
        
        var items: [WeeklyArchiveItem] = []
        var current = monthRange.start
        var weekNumber = 1
        var processedWeeks = Set<Date>()
        
        let today = Date()
        let currentWeekStart = calendar.weekRange(for: today)?.lowerBound ?? today
        let isTodaySunday = calendar.component(.weekday, from: today) == 1 // Minggu adalah 1
        
        while current < monthRange.end {
            // Gunakan extension weekRange yang konsisten (Senin sebagai awal minggu)
            guard let weekInterval = calendar.weekRange(for: current) else { break }
            let weekStart = weekInterval.lowerBound
            // weekEnd untuk keperluan UI adalah 1 hari sebelum awal minggu berikutnya (yaitu hari Minggu)
            guard let weekEnd = calendar.date(byAdding: .day, value: -1, to: weekInterval.upperBound) else { break }
            
            if !processedWeeks.contains(weekStart) {
                processedWeeks.insert(weekStart)
                
                // Fetch Recap for this week
                let predicate = #Predicate<Recap> { recap in
                    recap.weekStart == weekStart
                }
                let descriptor = FetchDescriptor<Recap>(predicate: predicate)
                let recap = try? context.fetch(descriptor).first
                
                // Logic kemunculan card:
                // 1. Jika sudah diisi (recap != nil), selalu munculkan (arsip).
                // 2. Jika minggu sudah lewat (past week), munculkan (baik isi maupun oops).
                // 3. Jika minggu ini sedang berjalan (current week), munculkan HANYA jika hari ini Minggu (isTodaySunday).
                // 4. Jika minggu depan (future week), JANGAN munculkan.
                
                let isPastWeek = weekStart < currentWeekStart
                let isCurrentWeek = weekStart == currentWeekStart
                let shouldShow = recap != nil || isPastWeek || (isCurrentWeek && isTodaySunday)
                
                if shouldShow {
                
                // Calculate date range string
                let dateRangeStr = formatWeekRange(start: weekStart, end: weekEnd)
                
                // Calculate total reflections for this week
                let nextWeekStart = weekInterval.upperBound
                let refPredicate = #Predicate<Reflection> { ref in
                    ref.date >= weekStart && ref.date < nextWeekStart
                }
                let refDescriptor = FetchDescriptor<Reflection>(predicate: refPredicate)
                let refCount = (try? context.fetchCount(refDescriptor)) ?? 0
                
                items.append(WeeklyArchiveItem(
                    weekNumber: weekNumber,
                    startDate: weekStart,
                    endDate: weekEnd,
                    dateRangeString: dateRangeStr,
                    recap: recap,
                    totalReflections: refCount
                ))
                weekNumber += 1
                }
            }
            
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        self.weeklyArchiveItems = items
    }
    
    private func formatWeekRange(start: Date, end: Date) -> String {
        let startMonth = calendar.component(.month, from: start)
        let endMonth = calendar.component(.month, from: end)
        let startYear = calendar.component(.year, from: start)
        let endYear = calendar.component(.year, from: end)
        
        let dayFormatter = DateFormatter()
        dayFormatter.locale = Locale(identifier: "id_ID")
        dayFormatter.dateFormat = "d"
        
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "id_ID")
        monthFormatter.dateFormat = "MMMM"
        
        let yearFormatter = DateFormatter()
        yearFormatter.locale = Locale(identifier: "id_ID")
        yearFormatter.dateFormat = "yyyy"
        
        if startYear != endYear {
            return "\(dayFormatter.string(from: start)) \(monthFormatter.string(from: start)) \(yearFormatter.string(from: start)) - \(dayFormatter.string(from: end)) \(monthFormatter.string(from: end)) \(yearFormatter.string(from: end))"
        } else if startMonth != endMonth {
            return "\(dayFormatter.string(from: start)) \(monthFormatter.string(from: start)) - \(dayFormatter.string(from: end)) \(monthFormatter.string(from: end)) \(yearFormatter.string(from: end))"
        } else {
            return "\(dayFormatter.string(from: start))-\(dayFormatter.string(from: end)) \(monthFormatter.string(from: start)) \(yearFormatter.string(from: start))"
        }
    }
}
