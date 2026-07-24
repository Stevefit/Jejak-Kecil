//
//  Recap.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 21/07/26.
//

import Foundation
import SwiftData

// MARK: recap (weekly)

@Model
final class Recap {

    // dibuat unique, satu recap per minggu.
    // Logic weeknya di VM 
    #Unique<Recap>([\.weekStart])
    var weekStart: Date

    // WQ1: refleksi paling berkesan yang dipilih (refleksi sudah mencakup moment).
    // dipilih dari refleksi minggu ini saja. nullify: hapus recap != hapus refleksi.
    @Relationship(deleteRule: .nullify)
    var highlightedReflection: Reflection?

    // WQ2: jawaban essay. cascade: hapus recap ikut hapus jawaban.
    @Relationship(deleteRule: .cascade, inverse: \Answer.recap)
    var essayAnswer: Answer?

    var isCompleted: Bool

    init(
        weekStart: Date,
        highlightedReflection: Reflection? = nil,
        essayAnswer: Answer? = nil,
        isCompleted: Bool = false
    ) {
        self.weekStart = weekStart
        self.highlightedReflection = highlightedReflection
        self.essayAnswer = essayAnswer
        self.isCompleted = isCompleted
    }
}
