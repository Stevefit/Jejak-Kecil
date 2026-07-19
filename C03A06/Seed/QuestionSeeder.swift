//
//  QuestionSeeder.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 17/07/26.
//

import Foundation
import SwiftData

enum QuestionSeeder {
    @MainActor
    static func seed(in context: ModelContext) throws {
        let existingCount = try context.fetchCount(FetchDescriptor<Question>())
        guard existingCount == 0 else { return }
        for question in makeSeedQuestions() {
            context.insert(question)
        }
        try context.save()
    }
    
    static func makeSeedQuestions() -> [Question] {
        // q1 - inisiatif
        let q1 = Question(
            code: "Q1",
            scope: .daily,
            answerType: .multipleChoice,
            text: "Siapa yang memulai momen ini?",
            displayOrder: 1)
        q1.choices = [
            Choice(type: .a, text: "Aku yang memulai", question: q1),
            Choice(type: .b, text: "Anakku yang memulai", question: q1),
            Choice(type: .c, text: "Orang lain yang memulai", question: q1),
        ]
        
        // fq1
        let fq1 = Question(
            code: "FQ1",
            scope: .daily,
            answerType: .essay,
            text: "Besok, adakah hal kecil yang ingin Anda mulai sendiri?",
            displayOrder: 2,
            triggerQuestionCode: "Q1",
            triggerChoiceType: .c
        )
        
        //q2 - keterlibatan
        let q2 = Question(
            code: "Q2",
            scope: .daily,
            answerType: .multipleChoice,
            text: "Seberapa terlibat Anda dan anak selama momen ini?",
            displayOrder: 3)
        q2.choices = [
            Choice(type: .a, text: "Hanya berada di tempat yang sama (keterlibatan rendah)", question: q2),
            Choice(type: .b, text: "Terlibat sebagian, sambil melakukan hal lain", question: q2),
            Choice(type: .c, text: "Terlibat sepenuhnya dan saling fokus satu sama lain", question: q2),
        ]
        
        // q3 - keterbukaan
        let q3 = Question(
            code: "Q3",
            scope: .daily,
            answerType: .multipleChoice,
            text: "Seberapa terbuka komunikasi yang terjadi dalam momen ini?",
            displayOrder: 4)
        q3.choices = [
            Choice(type: .a, text: "Anak menceritakan sesuatu yang biasanya tidak ia ceritakan", question: q3),
            Choice(type: .b, text: "Percakapan berlangsung seperti biasa, terbuka, dan santai", question: q3),
            Choice(type: .c, text: "Komunikasi terbatas, hanya percakapan singkat atau hening", question: q3),
        ]
        
        // q4 - perasaan
        let q4 = Question(
            code: "Q4",
            scope: .daily,
            answerType: .chip,
            text: "Perasaan apa yang Anda rasakan setelah momen tersebut?",
            displayOrder: 5,
            chipOptions: ["Hangat", "Bangga", "Tergesa-gesa", "Datar", "Ragu"]
        )
        
        // q5 - momen diingat anak
        let q5 = Question(
            code: "Q5",
            scope: .daily,
            answerType: .chip,
            text: "Apakah ada momen hari ini yang menurut Anda akan diingat oleh anak Anda?",
            displayOrder: 6,
            chipOptions: ["Iya", "Mungkin", "Tidak hari ini"]
        )
        
        // fq2
        let fq2 = Question(
            code: "FQ2",
            scope: .daily,
            answerType: .essay,
            text: "Apa yang Anda lakukan sehingga momen itu bisa terjadi? (Jika Iya)",
            displayOrder: 7,
            triggerQuestionCode: "Q5",
            triggerChipValue: "Iya"
        )

        //q6 - perbedaan momen
        let q6 = Question(
            code: "Q6",
            scope: .daily,
            answerType: .essay,
            text: "Apa yang membuat momen tersebut terasa berbeda dibandingkan momen lainnya hari ini?",
            displayOrder: 8)
        
     return [q1, fq1, q2, q3, q4, q5, fq2, q6]
    }
}

