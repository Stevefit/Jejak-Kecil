//
//  Reflection.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import Foundation
import SwiftData

// MARK: reflection

@Model
final class Reflection {

    var date: Date

    var moment: Moment?

    @Relationship(deleteRule: .cascade, inverse: \Answer.reflection)
    var answers: [Answer] = []

    // Sisi balik dari Recap.highlightedReflection (WQ1). Tidak dibaca kode mana pun,
    // tapi wajib ada: tanpa inverse, SwiftData tidak tahu Recap mana yang menunjuk
    // refleksi ini saat dihapus, dan Recap akan menyimpan rujukan ke objek mati.
    // cascade: refleksi yang jadi sorotan hilang berarti recap mingguannya ikut
    // hilang, jadi arsip minggu itu kembali ke kartu "Oops".
    @Relationship(deleteRule: .cascade, inverse: \Recap.highlightedReflection)
    var highlightedInRecap: Recap?

    // biar bisa isi nanti
    var isCompleted: Bool

    init(
        date: Date,
        moment: Moment? = nil,
        answers: [Answer] = [],
        isCompleted: Bool = false
    ) {
        self.date = date
        self.moment = moment
        self.answers = answers
        self.isCompleted = isCompleted
    }
}

// MARK: answer

@Model
final class Answer {

    var question: Question
    var answeredAt: Date

    // cuma satu dari tiga field ini yang terisi, trgntg question.answerType
    var selectedChoice: Choice?
    var selectedChip: String?
    var essayText: String?

    // cuma salah satu (reflection ATAU recap) yang terisi per instance.
    var reflection: Reflection?
    var recap: Recap?

    init(
        question: Question,
        answeredAt: Date = .now,
        selectedChoice: Choice? = nil,
        selectedChip: String? = nil,
        essayText: String? = nil,
        reflection: Reflection? = nil,
        recap: Recap? = nil
    ) {
        self.question = question
        self.answeredAt = answeredAt
        self.selectedChoice = selectedChoice
        self.selectedChip = selectedChip
        self.essayText = essayText
        self.reflection = reflection
        self.recap = recap
    }
}
