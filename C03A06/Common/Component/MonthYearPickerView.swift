import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date

    private var calendar: Calendar { Calendar.current }
    private var now: Date { Date() }

    private var months: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.standaloneMonthSymbols
    }

    private var currentYear: Int {
        calendar.component(.year, from: now)
    }

    private var currentMonthIndex: Int {
        calendar.component(.month, from: now) - 1
    }

    private var years: [Int] {
        Array(2020...currentYear)
    }

    private var availableMonthsCount: Int {
        if selectedYear.wrappedValue == currentYear {
            return currentMonthIndex + 1
        } else {
            return months.count
        }
    }

    private var selectedMonth: Binding<Int> {
        Binding(
            get: {
                let month = calendar.component(.month, from: selectedDate) - 1
                return min(month, availableMonthsCount - 1)
            },
            set: { newMonth in
                updateDate(month: newMonth + 1, year: selectedYear.wrappedValue)
            }
        )
    }

    private var selectedYear: Binding<Int> {
        Binding(
            get: {
                let year = calendar.component(.year, from: selectedDate)
                return min(year, currentYear)
            },
            set: { newYear in
                let targetYear = min(newYear, currentYear)
                var targetMonth = selectedMonth.wrappedValue
                if targetYear == currentYear {
                    targetMonth = min(targetMonth, currentMonthIndex)
                }
                updateDate(month: targetMonth + 1, year: targetYear)
            }
        )
    }

    var body: some View {
        HStack {
            Picker("Bulan", selection: selectedMonth) {
                ForEach(0..<availableMonthsCount, id: \.self) { index in
                    Text(months[index].capitalized).tag(index)
                }
            }
            .pickerStyle(.wheel)

            Picker("Tahun", selection: selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(format: "%d", year)).tag(year)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding(.horizontal)
    }

    private func updateDate(month: Int, year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let newDate = calendar.date(from: components) {
            let clampedDate = min(newDate, now)
            selectedDate = calendar.startOfDay(for: clampedDate)
        }
    }
}

#Preview {
    MonthYearPickerView(selectedDate: .constant(Date()))
}
