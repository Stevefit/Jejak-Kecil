//
//  Moment.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//
//
//  Moment.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import Foundation
import SwiftData

enum MomentCategory: String, Codable, CaseIterable {
    case bermainBersama = "Bermain bersama"
    case ngobrolDanCerita = "Ngobrol & cerita"
    case aktivitasRutin = "Aktivitas rutin (makan, mandi, antar sekolah)"
    case belajarDanEksplorasi = "Belajar & eksplorasi"
    case pergiBersama = "Pergi bersama"
    case berkreasiBersama = "Berkreasi bersama (crafting, masak, eksperimen)"
}

@Model
final class Moment {
    @Attribute(.externalStorage) var photo: Data
    var timestamp: Date
    var shortDescription: String
    var category: MomentCategory

    @Relationship(deleteRule: .cascade, inverse: \Reflection.moment)
    var reflection: Reflection?

    init(
        photo: Data,
        timestamp: Date,
        shortDescription: String,
        category: MomentCategory,
        reflection: Reflection? = nil
    ) {
        self.photo = photo
        self.timestamp = timestamp
        self.shortDescription = shortDescription
        self.category = category
        self.reflection = reflection
    }
}
