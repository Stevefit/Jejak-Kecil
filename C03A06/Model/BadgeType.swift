//
//  BadgeType.swift
//  C03A06
//
//  Katalog lencana: identitas, judul, dan deskripsi yang tampil ke user.
//  Murni metadata (bukan @Model) — yang tersimpan di database cuma rawValue-nya.
//

import Foundation

// MARK: - Kategori lencana

enum BadgeCategory: String, CaseIterable, Sendable {
    case polaRefleksi = "Pola Refleksi"
    case kuantitas = "Kuantitas"
}

// MARK: - Lencana

enum BadgeType: String, CaseIterable, Sendable {

    // Kategori 1: pola refleksi (dari jawaban Q1-Q3)
    case rumahSiKecil
    case yangSelaluAda
    case hadirPenuh
    case ruangTerbuka

    // Kategori 3: jumlah/kuantitas
    case pemulaMomen
    case semingguPenuh
    case refleksiRutin

    var category: BadgeCategory {
        switch self {
        case .rumahSiKecil, .yangSelaluAda, .hadirPenuh, .ruangTerbuka:
            return .polaRefleksi
        case .pemulaMomen, .semingguPenuh, .refleksiRutin:
            return .kuantitas
        }
    }

    var title: String {
        switch self {
        case .rumahSiKecil:   return "Rumah Si Kecil"
        case .yangSelaluAda:  return "Yang Selalu Ada"
        case .hadirPenuh:     return "Hadir Penuh"
        case .ruangTerbuka:   return "Ruang Terbuka"
        case .pemulaMomen:    return "Pemula Momen"
        case .semingguPenuh:  return "Seminggu Penuh"
        case .refleksiRutin:  return "Refleksi Rutin"
        }
    }

    var badgeDescription: String {
        switch self {
        case .rumahSiKecil:
            return "Anak jadi pihak yang memulai momen paling sering minggu ini."
        case .yangSelaluAda:
            return "Kamu jadi pihak yang memulai momen paling sering minggu ini."
        case .hadirPenuh:
            return "Keterlibatan kamu dan anak konsisten tinggi sepanjang minggu ini."
        case .ruangTerbuka:
            return "Komunikasi kalian berdua terasa terbuka sepanjang minggu ini."
        case .pemulaMomen:
            return "Momen pertamamu berhasil tercatat, langkah awal yang baik."
        case .semingguPenuh:
            return "Kamu mencatat momen setiap hari selama satu minggu penuh."
        case .refleksiRutin:
            return "Kamu sudah mengisi refleksi lebih dari lima kali."
        }
    }

    // Nama imageset di Assets.xcassets/Badge. Folder Badge tidak memakai
    // namespace, jadi namanya dipakai apa adanya tanpa awalan "Badge/".
    var imageName: String {
        switch self {
        case .rumahSiKecil:   return "RumahSiKecil"
        case .yangSelaluAda:  return "YangSelaluAda"
        case .hadirPenuh:     return "HadirPenuh"
        case .ruangTerbuka:   return "RuangTerbuka"
        case .pemulaMomen:    return "PemulaMoment"
        case .semingguPenuh:  return "SemingguPenuh"
        case .refleksiRutin:  return "RefleksiRutin"
        }
    }

    // Untuk lencana yang belum didapat.
    static let lockedImageName = "BadgeKosong"
}
