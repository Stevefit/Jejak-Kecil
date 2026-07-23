//
//  MonthYearPickerView.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 21/07/26.
//


//
//  MonthYearPickerView.swift
//  C03A06
//

import SwiftUI

struct MonthYearPickerView: View {
    @Binding var selectedDate: Date

    private var calendar: Calendar { Calendar.current }
    
    // Indonesian month names (or locale-based)
    private var months: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.standaloneMonthSymbols
    }
    
    // Year range
    private var years: [Int] {
        Array(2020...2035)
    }

    private var selectedMonth: Binding<Int> {
        Binding(
            get: { calendar.component(.month, from: selectedDate) - 1 },
            set: { newMonth in
                updateDate(month: newMonth + 1, year: selectedYear.wrappedValue)
            }
        )
    }

    private var selectedYear: Binding<Int> {
        Binding(
            get: { calendar.component(.year, from: selectedDate) },
            set: { newYear in
                updateDate(month: selectedMonth.wrappedValue + 1, year: newYear)
            }
        )
    }

    var body: some View {
        HStack {
            Picker("Bulan", selection: selectedMonth) {
                ForEach(0..<months.count, id: \.self) { index in
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
            selectedDate = newDate
        }
    }
}

#Preview {
    MonthYearPickerView(selectedDate: .constant(Date()))
}