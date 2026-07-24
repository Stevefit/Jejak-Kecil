//
//  MultipleChoiceSelector.swift
//  C03A06
//
//  Created by Natalie Grace Widjaja Kuswanto on 16/07/26.
//

import SwiftUI
import SwiftData

struct MultipleChoiceSelector: View {
    let question: Question
    let selected: Choice?
    let onSelect: (Choice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(sortedChoices) { choice in
                    Button {
                        onSelect(choice)
                    } label: {
                        Text(choice.text)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color(.systemBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(isSelected(choice) ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.primary)
                }
            }
        }
    }

    private var sortedChoices: [Choice] {
        question.choices.sorted { $0.type.rawValue < $1.type.rawValue }
    }

    private func isSelected(_ choice: Choice) -> Bool {
        selected?.persistentModelID == choice.persistentModelID
    }
}
