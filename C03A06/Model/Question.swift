//
//  Question.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import Foundation
import SwiftData

// MARK: Enums

enum QuestionScope: String, Codable, Sendable {
    case daily
    case weekly
    
}
 
enum QuestionAnswerType: String, Codable, Sendable {
    case multipleChoice
    case chip
    case essay
}

enum ChoiceType: String, Codable, Sendable {
    case a
    case b
    case c
}

// MARK: Q4 perasaan + deskripsi yang dipake di MomentCard
enum Mood: String, CaseIterable, Codable, Sendable {
    case hangat = "Hangat"
    case bangga = "Bangga"
    case tergesaGesa = "Tergesa-gesa"
    case datar = "Datar"
    case ragu = "Ragu"

    var reflectionDescription: String {
        switch self {
        case .hangat: return "Momen ini terasa hangat dan mengalir."
        case .bangga: return "Momen ini terasa penuh rasa bangga."
        case .tergesaGesa: return "Momen ini terasa singkat dan terburu-buru."
        case .datar: return "Momen ini terasa tenang tanpa banyak kesan."
        case .ragu: return "Momen ini terasa belum mudah dipahami."
        }
    }
}

// MARK: questions
@Model
final class Question {
    @Attribute(.unique) var code: String
    var scope: QuestionScope
    var answerType: QuestionAnswerType
    var text: String
    var displayOrder: Int
    
    // multiple choice answers
    @Relationship(deleteRule: .cascade, inverse: \Choice.question)
    var choices: [Choice] = []
    
    // chip
    var chipOptions: [String] = []
    
    // MARK: followup questions
    var triggerQuestionCode: String?
    var triggerChoiceType: ChoiceType?
    var triggerChipValue: String?
    init(
        code: String,
        scope: QuestionScope,
        answerType: QuestionAnswerType,
        text: String,
        displayOrder: Int,
        choices: [Choice] = [],
        chipOptions: [String] = [],
        triggerQuestionCode: String? = nil,
        triggerChoiceType: ChoiceType? = nil,
        triggerChipValue: String? = nil
    ) {
        self.code = code
        self.scope = scope
        self.answerType = answerType
        self.text = text
        self.displayOrder = displayOrder
        self.choices = choices
        self.chipOptions = chipOptions
        self.triggerQuestionCode = triggerQuestionCode
        self.triggerChoiceType = triggerChoiceType
        self.triggerChipValue = triggerChipValue
    }
    var isFollowUp: Bool {
        triggerQuestionCode != nil
    }
}

//MARK: choice
@Model
final class Choice {
    var type: ChoiceType
    var text: String
    var question: Question?
    init(type: ChoiceType, text: String, question: Question? = nil) {
        self.type = type
        self.text = text
        self.question = question
    }
}



