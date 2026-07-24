//
//  ReviewMomentViewModelTests.swift
//  C03A06
//
//  Created by Axel Valerio Ertamto on 20/07/26.
//



import Testing
import Foundation
import SwiftData
@testable import C03A06

@MainActor
@Suite("Review Recorded Moments and Reflections")
struct ReviewMomentViewModelTests {

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Moment.self, Reflection.self, Question.self, Choice.self, Answer.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }

    private func createDate(year: Int = 2026, month: Int = 7, day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        return Calendar.current.date(from: components)!
    }

    @Test("Belum memilih tanggal DAN ada beberapa momen serta refleksi yang sudah tersimpan di hari ini")
    func fetchDataLoadsCorrectDataForSelectedDate() throws {
        let context = try makeInMemoryContext()
        let targetDate = createDate(day: 20)
        let otherDate = createDate(day: 21)
        
        let moment1 = Moment(photo: Data([0x01]), timestamp: createDate(day: 20, hour: 9), shortDescription: "Morning stroll", category: .bermainBersama)
        let moment2 = Moment(photo: Data([0x02]), timestamp: createDate(day: 20, hour: 15), shortDescription: "Reading books", category: .belajarDanEksplorasi)
        let outsideMoment = Moment(photo: Data([0x03]), timestamp: otherDate, shortDescription: "Wrong day moment", category: .pergiBersama)
        
        let reflection = Reflection(date: targetDate, moment: moment1, isCompleted: true)
        let outsideReflection = Reflection(date: otherDate, moment: outsideMoment, isCompleted: true)
        
        context.insert(moment1)
        context.insert(moment2)
        context.insert(outsideMoment)
        context.insert(reflection)
        context.insert(outsideReflection)
        try context.save()
        
        let viewModel = ReviewMomentViewModel()
        viewModel.modelContext = context
        
        viewModel.changeDate(to: targetDate)
        
        #expect(viewModel.moments.count == 2)
        #expect(viewModel.moments.contains { $0.shortDescription == "Morning stroll" })
        #expect(viewModel.moments.contains { $0.shortDescription == "Reading books" })
        #expect(viewModel.reflection?.persistentModelID == reflection.persistentModelID)
    }

    @Test("Belum memilih tanggal DAN tidak ada momen atau refleksi sama sekali yang tercatat pada hari tersebut")
    func fetchDataReturnsEmptyResultWhenNoDataOnSelectedDate() throws {
        let context = try makeInMemoryContext()
        let loggedDate = createDate(day: 19)
        let targetedEmptyDate = createDate(day: 20)
        
        let moment = Moment(photo: Data([0x01]), timestamp: loggedDate, shortDescription: "Yesterday memories", category: .bermainBersama)
        let reflection = Reflection(date: loggedDate, moment: moment, isCompleted: true)
        
        context.insert(moment)
        context.insert(reflection)
        try context.save()
        
        let viewModel = ReviewMomentViewModel()
        viewModel.modelContext = context
        
        viewModel.changeDate(to: targetedEmptyDate)
        
        #expect(viewModel.moments.isEmpty)
        #expect(viewModel.reflection == nil)
    }
    
    @Test("User sedang melihat detail momen yang sudah tersimpan")
    func updateMomentPersistsChangesAndRefreshesMoments() throws {
        let context = try makeInMemoryContext()
        let initialDate = createDate(day: 20, hour: 10)
        let updatedDate = createDate(day: 20, hour: 11)
        
        let moment = Moment(
            photo: Data([0x10]),
            timestamp: initialDate,
            shortDescription: "Original description",
            category: .bermainBersama
        )
        context.insert(moment)
        try context.save()
        
        let viewModel = ReviewMomentViewModel()
        viewModel.modelContext = context
        viewModel.selectedDate = createDate(day: 20)
        viewModel.fetchData()
        
        #expect(viewModel.moments.first?.shortDescription == "Original description")
        
        let newPhotoData = Data([0x20, 0x30])
        viewModel.updateMoment(
            moment,
            withDescription: "Successfully updated description",
            date: updatedDate,
            photoData: newPhotoData
        )
        
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.count == 1)
        #expect(savedMoments.first?.shortDescription == "Successfully updated description")
        #expect(savedMoments.first?.timestamp == updatedDate)
        #expect(savedMoments.first?.photo == newPhotoData)
        
        #expect(viewModel.moments.count == 1)
        #expect(viewModel.moments.first?.shortDescription == "Successfully updated description")
    }

    @Test("User hanya mengubah deskripsi atau tanggal tanpa memilih foto baru")
    func updateMomentPreservesOriginalPhotoWhenNewPhotoDataIsNil() throws {
        let context = try makeInMemoryContext()
        let momentDate = createDate(day: 20)
        let originalPhoto = Data([0xAB, 0xCD])
        
        let moment = Moment(
            photo: originalPhoto,
            timestamp: momentDate,
            shortDescription: "Old Text",
            category: .aktivitasRutin
        )
        context.insert(moment)
        try context.save()
        
        let viewModel = ReviewMomentViewModel()
        viewModel.modelContext = context
        
        viewModel.updateMoment(
            moment,
            withDescription: "New Text",
            date: momentDate,
            photoData: nil
        )
        
        let savedMoments = try context.fetch(FetchDescriptor<Moment>())
        #expect(savedMoments.first?.shortDescription == "New Text")
        #expect(savedMoments.first?.photo == originalPhoto)
    }
    
    @Test("Aplikasi sedang tidak bisa mengakses database sistem atau penyimpanan internal bermasalah")
    func fetchDataHandlesNilContextGracefully() async throws {
        let viewModel = ReviewMomentViewModel()
        viewModel.modelContext = nil
        viewModel.moments = [Moment(photo: Data(), timestamp: Date(), shortDescription: "Stale", category: .bermainBersama)]
        viewModel.reflection = Reflection(date: Date(), isCompleted: true)
        
        viewModel.fetchData()
        
        #expect(viewModel.moments.isEmpty)
        #expect(viewModel.reflection == nil)
    }
}
