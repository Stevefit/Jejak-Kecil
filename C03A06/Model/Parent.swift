//
//  Parent.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//

import Foundation
import SwiftData


enum ParentRole: String, Codable {
    case ayah
    case ibu
}

@Model
class Parent {
    var name: String
    var parentRole: ParentRole
    
    init(name: String, parentRole: ParentRole) {
        self.name = name
        self.parentRole = parentRole
    }
}


