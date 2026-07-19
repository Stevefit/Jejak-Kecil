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
}
