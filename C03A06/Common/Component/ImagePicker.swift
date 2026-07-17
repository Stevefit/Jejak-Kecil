//
//  ImagePicker.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 17/07/26.
//

import Foundation
import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    
    
    var sourceType: UIImagePickerController.SourceType    // Sumber Foto bisa .photoLibrary atau .camera
    
    @Binding var selectedImageData: Data? // Binding untuk mengembalikan data gambar yang telah dipilih/diambil
    @Environment(\.presentationMode) private var presentationMode // menutup tampilan setelah memilih gambar
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator // Set delegate ke Coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        //digunakan untuk update , tapi sekarang belum
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // Dipanggil ketika pengguna selesai memilih/mengambil gambar.
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Ambil gambar aslinya
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImageData = image.jpegData(compressionQuality: 0.8)
            }
            parent.presentationMode.wrappedValue.dismiss() // Tutup picker
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() // Dismiss ketika cancel
        }
    }
}
