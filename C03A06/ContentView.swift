//
//  ContentView.swift
//  C03A06
//
//  Created by Steve on 13/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showCreateMoment = false
    @State private var showReflectMoment = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Button("Buat Momen Baru") {
                    showCreateMoment = true
                }
                .buttonStyle(.borderedProminent)

                Button("Refleksi Hari Ini") {
                    showReflectMoment = true
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .sheet(isPresented: $showCreateMoment) {
            CreateMomentView()
        }
        .sheet(isPresented: $showReflectMoment) {
            ReflectMomentView(onClose: { showReflectMoment = false })
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Moment.self, Reflection.self, Question.self, Choice.self, Answer.self], inMemory: true)
}
