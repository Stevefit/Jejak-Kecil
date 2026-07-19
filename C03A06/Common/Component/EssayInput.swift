//
//  EssayInput.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 16/07/26.
//

import SwiftUI

struct EssayInput: View {
    let question: Question
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(question.text)
                    .font(.headline)

                Spacer()

                Text("Opsional")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.systemGray5)))
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))

                if text.isEmpty {
                    Text("Opsional")
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }
            .frame(height: 100)
        }
    }
}
