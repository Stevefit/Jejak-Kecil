//
//   HalfSizeImage.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 26/07/26.
//

import SwiftUI
// dipakai kalau download aset sketch pake 2x
// agar pas 1:1 dengan sketch tanpa hardcode angka.
struct HalfSizeImage: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        if let ui = UIImage(named: name) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(width: ui.size.width / 2, height: ui.size.height / 2)
        }
    }
}
