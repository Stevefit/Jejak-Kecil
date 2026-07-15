//
//  Moment.swift
//  C03A06
//
//  Created by Steve on 14/07/26.
//

import Foundation
import SwiftData

@Model
final class Moment {
    @Attribute(.externalStorage) var photo: Data
    var timestamp: Date
    var shortDescription: String?

    @Relationship(deleteRule: .cascade, inverse: \Reflection.moment)
    var reflection: Reflection?

    init(
        photo: Data,
        timestamp: Date,
        shortDescription: String? = nil,
        reflection: Reflection? = nil
    ) {
        self.photo = photo
        self.timestamp = timestamp
        self.shortDescription = shortDescription
        self.reflection = reflection
    }
}
