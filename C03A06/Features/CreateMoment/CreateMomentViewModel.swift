//
//  CreateMomentViewModel.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 17/07/26.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
final class CreateMomentViewModel {
    
    // MARK: - Properties
    
    var date: Date = .now  //set tanggal default ke hari ini.
    var description: String = ""
    var selectedCategory: MomentCategory? = nil 
    var photoData: Data? = nil
    
    
    // Validasi form
    var isFormValid: Bool {
        let isDescriptionValid = !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty //trimming untuk remove whitespace di awal dan akhir
        let isPhotoValid = photoData != nil
        let isCategoryValid = selectedCategory != nil
        
        return isDescriptionValid && isPhotoValid && isCategoryValid
    }
    
    // MARK: - Save Function (SwiftData)
    func save(context: ModelContext) {
        //double check validasi sebelum menyimpan
        guard isFormValid, 
              let photo = photoData,
              let category = selectedCategory
        else {
            print("Form is not valid") //Tambah error msg
            return
        }
        
        // Buat objek Moment baru
        let newMoment = Moment(
            photo: photo,
            timestamp: date,
            shortDescription: description,
            category: category
        )
        
        context.insert(newMoment)
    }
}

