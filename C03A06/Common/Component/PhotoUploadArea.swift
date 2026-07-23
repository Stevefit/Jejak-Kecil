//
//  PhotoUploadArea.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 20/07/26.
//

import SwiftUI

// Area untuk menampilkan preview foto atau placeholder unggah foto.
// Menampilkan gambar jika `photoData` tersedia, jika tidak menampilkan placeholder.
struct PhotoUploadArea: View {
    let photoData: Data?
    let action: () -> Void

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .overlay {
                if let photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    VStack(spacing: 8) {
                        Text("Ambil/Unggah Foto")
                            .foregroundStyle(Color.gray)
                            .font(.headline)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(RoundedRectangle(cornerRadius: 24))
            .onTapGesture(perform: action)
    }
}

#Preview("Placeholder") {
    PhotoUploadArea(photoData: nil, action: {})
        .padding()
}
