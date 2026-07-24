//
//  Extensions.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import Foundation

extension Calendar {
    /// Rentang setengah terbuka [awal hari, awal hari berikutnya) untuk
    /// memfilter entitas yang jatuh pada tanggal tertentu.
    func dayRange(for date: Date) -> Range<Date>? {
        let start = startOfDay(for: date)
        guard let end = self.date(byAdding: .day, value: 1, to: start) else { return nil }
        return start..<end
    }

    // untuk cari range week yang mengandung date 
    // firstWeekday dipaksa Senin (2), gak ikut locale device.
    func weekRange(for date: Date) -> Range<Date>? {
        var calendar = self
        calendar.firstWeekday = 2
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return nil }
        return interval.start..<interval.end
    }
}
