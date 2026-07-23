//
//  CreateMomentIntent.swift
//  C03A06
//
//  App Intent untuk membuat Moment baru dari Widget / Shortcuts.
//
import AppIntents
import SwiftData
import UniformTypeIdentifiers
import Foundation

struct CreateMomentIntent: AppIntent {

    static var title: LocalizedStringResource = "Tambah Momen"

    static var description = IntentDescription(
        "Membuka form untuk menambahkan momen baru."
    )

    static var openAppWhenRun: Bool = true

    @Parameter(title: "Deskripsi")
    var momentDescription: String?

    @Parameter(title: "Kategori")
    var category: MomentCategory?

    @Parameter(title: "Tanggal")
    var date: Date?

    @Parameter(title: "Foto", supportedContentTypes: [.image])
    var photo: IntentFile?

    static var parameterSummary: some ParameterSummary {
        Summary("Tambah momen") {
            \.$momentDescription
            \.$category
            \.$date
            \.$photo
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        UserDefaults.standard.set(true, forKey: "shouldShowCreateMomentFromWidget")
        return .result()
    }
}

// MARK: kategori momen

extension MomentCategory: AppEnum {
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Kategori Momen"
    }

    nonisolated static var caseDisplayRepresentations: [MomentCategory: DisplayRepresentation] {
        [
            .bermainBersama: "Bermain bersama",
            .ngobrolDanCerita: "Ngobrol & cerita",
            .aktivitasRutin: "Aktivitas rutin",
            .belajarDanEksplorasi: "Belajar & eksplorasi",
            .pergiBersama: "Pergi bersama",
            .berkreasiBersama: "Berkreasi bersama"
        ]
    }
}

// MARK: app shortcut provider

struct MomentAppShortcuts: AppShortcutsProvider {
    
    static var shortcutTileColor: ShortcutTileColor = .blue
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateMomentIntent(),
            phrases: [
                "Tambah momen di \(.applicationName)",
                "Catat momen baru di \(.applicationName)"
            ],
            shortTitle: "Tambah Momen",
            systemImageName: "plus.circle.fill"
        )
    }
}
