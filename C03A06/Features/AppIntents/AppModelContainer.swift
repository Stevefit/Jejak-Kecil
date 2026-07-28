//
//  AppModelContainer.swift
//  C03A06
//
//  Container SwiftData bersama supaya aplikasi dan App Intent (Shortcut)
//  menulis ke database yang sama.
//

import SwiftData
import Foundation

enum AppModelContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            Item.self,
            Moment.self,
            Reflection.self,
            Question.self,
            Choice.self,
            Answer.self,
            Recap.self,
            EarnedBadge.self
        ])

        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = appSupportURL.appendingPathComponent("C03A06Database.sqlite")
        
        try? FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)

        let configuration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
