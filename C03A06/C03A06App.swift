import SwiftUI
import SwiftData

@main
struct C03A06App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Moment.self,
            Reflection.self,
            Answer.self,
            Question.self,
            Choice.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Fix: Run synchronously on the MainActor immediately to block race conditions
            let context = container.mainContext
            
            // Create a temporary dummy image payload
            if let placeholderData = UIImage(systemName: "camera.fill")?
                .jpegData(compressionQuality: 0.8) {
                
                // Normalize dates to the middle of today to guarantee they fall inside the predicate window
                let calendar = Calendar.current
                let todayMidday = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
                
                let moment1 = Moment(
                    photo: placeholderData,
                    timestamp: todayMidday,
                    shortDescription: "Main bikin rumah-rumahan sama Lili di ruang tengah."
                )
                
                let moment2 = Moment(
                    photo: placeholderData,
                    timestamp: todayMidday.addingTimeInterval(3600),
                    shortDescription: "Mewarnai gambar pemandangan bareng adik hari ini."
                )
                
                context.insert(moment1)
                context.insert(moment2)
                
                try? context.save()
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ReviewMomentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
