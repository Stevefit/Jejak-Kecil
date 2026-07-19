//
//  ChipDropDownSelector.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 16/07/26.
//

import SwiftUI

struct ChipDropdownSelector: View {
    let question: Question
    let selected: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.headline)

            Menu {
                ForEach(question.chipOptions, id: \.self) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        if selected == option {
                            Label(option, systemImage: "checkmark")
                        } else {
                            Text(option)
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selected ?? "Pilih")
                        .foregroundStyle(selected == nil ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(.plain)
        }
    }
}
