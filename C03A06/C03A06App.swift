//
//  C03A06App.swift
//  C03A06
//
//  Created by Steve on 13/07/26.
//

import SwiftUI
import SwiftData

@main
struct C03A06App: App {
    var sharedModelContainer: ModelContainer = {
        //model di database
        let schema = Schema([
            Item.self,
            Moment.self,
            Reflection.self,
            Question.self,
            Choice.self,
            Answer.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await seedQuestionsIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
       private func seedQuestionsIfNeeded() async {
           let context = sharedModelContainer.mainContext
           do {
               try QuestionSeeder.seed(in: context)
           } catch {
               print("Gagal melakukan seeding Question: \(error)")
           }
       }
}


