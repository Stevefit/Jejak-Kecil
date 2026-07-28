import SwiftUI
import SwiftData
import AppIntents

@main
struct C03A06App: App {

    init() {
        MomentAppShortcuts.updateAppShortcutParameters()
    }
    var sharedModelContainer: ModelContainer = {
        //model di database
        let schema = Schema([
            Item.self,
            Moment.self,
            Reflection.self,
            Question.self,
            Choice.self,
            Answer.self,
            Recap.self,
            Parent.self
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
        .modelContainer(AppModelContainer.shared)    }
   
    
    @MainActor
       private func seedQuestionsIfNeeded() async {
           let context = sharedModelContainer.mainContext
           do {
               try QuestionSeeder.seed(in: context)
               try RecapQuestionSeeder.seed(in: context)
           } catch {
               print("Gagal melakukan seeding Question: \(error)")
           }
       }
}


