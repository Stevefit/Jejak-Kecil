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
