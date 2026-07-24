//
//  MomentWidget.swift
//  MomentWidget
//
//  Created by Natalie Grace Widjaja Kuswanto on 21/07/26.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries = [SimpleEntry(date: Date())]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct MomentWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            Button(intent: CreateMomentIntent()) {
                VStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 34))
                        .foregroundColor(.blue)
                    
                    Text("Tambah Momen")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct MomentWidget: Widget {
    let kind: String = "MomentWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MomentWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Tambah Momen")
        .description("Pintasan cepat untuk menambahkan momen baru.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MomentWidget()
} timeline: {
    SimpleEntry(date: .now)
}
