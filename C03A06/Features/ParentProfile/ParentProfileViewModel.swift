//
//  ParentProfileViewModel.swift
//  C03A06
//
//  Created by Steve on 21/07/26.
//
import Foundation
import SwiftData

@Observable
class ParentProfileViewModel {
    var parent: Parent?
    var isShowingEditSheet = false

    // Berapa minggu tiap lencana pernah didapat, untuk daftar lencana.
    private(set) var badgeCounts: [BadgeType: Int] = [:]

    private var modelContext: ModelContext

    // BadgeService ber-@MainActor, jadi init dan fetchBadges ikut diisolasi.
    @MainActor
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchParent()
        fetchBadges()
    }

    func fetchParent() {
        let descriptor = FetchDescriptor<Parent>()
        do {
            parent = try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to fetch parent: \(error)")
        }
    }

    @MainActor
    func fetchBadges() {
        badgeCounts = BadgeService.earnedCounts(context: modelContext)
    }

    /// Call once on appear in case no profile exists yet
    func createParentIfNeeded(name: String = "Nama Orangtua", role: ParentRole = .ayah) {
        guard parent == nil else { return }
        let newParent = Parent(name: name, parentRole: role)
        modelContext.insert(newParent)
        saveContext()
        parent = newParent
    }

    func updateParent(name: String, role: ParentRole) {
        guard let parent else { return }
        parent.name = name
        parent.parentRole = role
        saveContext()
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
