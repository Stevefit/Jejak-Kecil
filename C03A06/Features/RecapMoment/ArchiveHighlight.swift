//
//  ArchiveHighlight.swift
//  C03A06
//
//  Created by Deny Wahyudi Asaloei  on 26/07/26.
//

import SwiftUI

// MARK: - Anchor tombol Arsip
// Menyimpan frame tombol Arsip agar overlay bisa dilubangi di posisi yang sama.
struct ArchiveAnchorKey: PreferenceKey {
    static let defaultValue: Anchor<CGRect>? = nil
    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = nextValue() ?? value
    }
}

// MARK: - Reverse mask (lubang)
extension View {
    // Kebalikan `mask`: area yang digambar `content` justru dibuat transparan (berlubang).
    func reverseMask<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        mask {
            Rectangle()
                .overlay {
                    content().blendMode(.destinationOut)
                }
        }
    }
}
