//
//  CreateMomentViewModelTests.swift
//  C03A06Tests
//
//  Created by Deny Wahyudi Asaloei  on 17/07/26.
//
import Testing
import SwiftData
import SwiftUI
@testable import C03A06

@MainActor
struct CreateMomentViewModelTests {

    // MARK: - Helper

    // Membuat ModelContext in-memory untuk keperluan testing SwiftData
    // Database sementara
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Moment.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    // Data foto dummy 1 byte, cukup untuk mengisi field photoData.
    private var dummyPhotoData: Data {
        Data([0x00])
    }

    // MARK: - isFormValid

    @Test("Form valid ketika description, photo, dan category semuanya terisi")
    func formValid_whenAllFieldsFilled() {
        // Given: semua field diisi dengan benar
        let vm = CreateMomentViewModel()
        vm.description = "Main bersama di taman"
        vm.photoData = dummyPhotoData
        vm.selectedCategory = .bermainBersama

        // When: isFormValid dievaluasi
        let result = vm.isFormValid

        // Then: hasilnya true
        #expect(result == true)
    }

    @Test("Form tidak valid ketika description kosong")
    func formInvalid_whenDescriptionEmpty() {
        // Given: description kosong, field lain terisi
        let vm = CreateMomentViewModel()
        vm.description = ""
        vm.photoData = dummyPhotoData
        vm.selectedCategory = .bermainBersama

        // When: isFormValid dievaluasi
        let result = vm.isFormValid

        // Then: hasilnya false
        #expect(result == false)
    }

    @Test("Form tidak valid ketika description hanya berisi whitespace")
    func formInvalid_whenDescriptionOnlyWhitespace() {
        // Given: description hanya berisi spasi dan newline
        let vm = CreateMomentViewModel()
        vm.description = "   \n  "
        vm.photoData = dummyPhotoData
        vm.selectedCategory = .bermainBersama

        // When: isFormValid dievaluasi
        let result = vm.isFormValid

        // Then: hasilnya false karena trimming menghasilkan string kosong
        #expect(result == false)
    }

    @Test("Form tidak valid ketika photoData nil")
    func formInvalid_whenPhotoDataNil() {
        // Given: photoData belum diisi
        let vm = CreateMomentViewModel()
        vm.description = "Main bersama di taman"
        vm.photoData = nil
        vm.selectedCategory = .bermainBersama

        // When: isFormValid dievaluasi
        let result = vm.isFormValid

        // Then: hasilnya false
        #expect(result == false)
    }

    @Test("Form tidak valid ketika selectedCategory nil")
    func formInvalid_whenCategoryNil() {
        // Given: kategori belum dipilih
        let vm = CreateMomentViewModel()
        vm.description = "Main bersama di taman"
        vm.photoData = dummyPhotoData
        vm.selectedCategory = nil

        // When: isFormValid dievaluasi
        let result = vm.isFormValid

        // Then: hasilnya false
        #expect(result == false)
    }

    // MARK: - save(context:)

    @Test("save() menyimpan Moment baru ketika form valid")
    func save_insertsMoment_whenFormValid() throws {
        // Given: form terisi dan valid
        let context = try makeInMemoryContext()
        let vm = CreateMomentViewModel()
        vm.description = "Membacakan cerita sebelum tidur"
        vm.photoData = dummyPhotoData
        vm.selectedCategory = .bermainBersama

        // When: save moment
        vm.save(context: context)

        // Then: satu Moment baru berhasil tersimpan dengan data yang sesuai
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.count == 1)
        #expect(savedMoments.first?.shortDescription == "Membacakan cerita sebelum tidur")
        #expect(savedMoments.first?.photo == dummyPhotoData)
        #expect(savedMoments.first?.category == .bermainBersama)
    }

    @Test("save() tidak menyimpan apa pun ketika description kosong")
    func save_doesNothing_whenDescriptionEmpty() throws {
        // Given: context in-memory dan description kosong
        let context = try makeInMemoryContext()
        let vm = CreateMomentViewModel()
        vm.description = ""
        vm.photoData = dummyPhotoData
        vm.selectedCategory = .bermainBersama

        // When: save dipanggil
        vm.save(context: context)

        // Then: tidak ada Moment yang tersimpan
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.isEmpty)
    }

    @Test("save() tidak menyimpan apa pun ketika photoData nil")
    func save_doesNothing_whenPhotoDataNil() throws {
        // Given: context in-memory dan photoData belum diisi
        let context = try makeInMemoryContext()
        let vm = CreateMomentViewModel()
        vm.description = "Membacakan cerita sebelum tidur"
        vm.photoData = nil
        vm.selectedCategory = .bermainBersama

        // When: save dipanggil
        vm.save(context: context)

        // Then: tidak ada Moment yang tersimpan
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.isEmpty)
    }

    @Test("save() tidak menyimpan apa pun ketika selectedCategory nil")
    func save_doesNothing_whenCategoryNil() throws {
        // Given: context in-memory dan kategori belum dipilih
        let context = try makeInMemoryContext()
        let vm = CreateMomentViewModel()
        vm.description = "Membacakan cerita sebelum tidur"
        vm.photoData = dummyPhotoData
        vm.selectedCategory = nil

        // When: save dipanggil
        vm.save(context: context)

        // Then: tidak ada Moment yang tersimpan
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.isEmpty)
    }
}
