//
//  EarnedBadge.swift
//  C03A06
//
//  Lencana yang sudah didapat user pada satu minggu tertentu.
//

import Foundation
import SwiftData

// MARK: earned badge (weekly)

@Model
final class EarnedBadge {

    // Satu lencana hanya boleh muncul sekali per minggu.
    #Unique<EarnedBadge>([\.rawType, \.weekStart])

    // Disimpan sebagai String, bukan enum: Codable enum berisiko crash di #Predicate,
    // sama seperti catatan di RecapQuestionSeeder.
    var rawType: String

    var weekStart: Date
    var earnedAt: Date

    var type: BadgeType? { BadgeType(rawValue: rawType) }

    init(type: BadgeType, weekStart: Date, earnedAt: Date = .now) {
        self.rawType = type.rawValue
        self.weekStart = weekStart
        self.earnedAt = earnedAt
    }
}
