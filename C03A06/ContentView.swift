//
//  ContentView.swift
//  C03A06
//
//  Created by Steve on 13/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ReviewMomentView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Moment.self, Reflection.self, Question.self, Choice.self, Answer.self], inMemory: true)
}
