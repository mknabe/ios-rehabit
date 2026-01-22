//
//  PastDueWidget.swift
//  PastDueWidget
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import WidgetKit
import SwiftData
import RoutineCheckShared

struct PastDueEntry: TimelineEntry {
    let date: Date
    let routines: [PastDueRoutineEntry]
    let totalCount: Int
}

struct PastDueRoutineEntry: Identifiable {
    let id: UUID
    let emoji: String
    let name: String
    let overdueText: String
}

struct PastDueProvider: TimelineProvider {
    func placeholder(in context: Context) -> PastDueEntry {
        PastDueEntry(
            date: Date(),
            routines: [
                PastDueRoutineEntry(id: UUID(), emoji: "✂️", name: "Trim Hair", overdueText: "9 mths, 9 days")
            ],
            totalCount: 1
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PastDueEntry) -> Void) {
        completion(loadEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PastDueEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func loadEntry() -> PastDueEntry {
        do {
            let container = try SharedModelContainer.makeContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Routine>()
            let routines = try context.fetch(descriptor)
            let pastDue = routines
                .filter { $0.isPastDue }
                .sorted { ($0.pastDueDate ?? .distantPast) < ($1.pastDueDate ?? .distantPast) }
            
            let entries = pastDue.prefix(3).map { routine in
                PastDueRoutineEntry(
                    id: routine.id,
                    emoji: routine.emoji,
                    name: routine.name,
                    overdueText: overdueText(for: routine)
                )
            }
            
            return PastDueEntry(
                date: Date(),
                routines: entries,
                totalCount: pastDue.count
            )
        } catch {
            return PastDueEntry(date: Date(), routines: [], totalCount: 0)
        }
    }
    
    private func overdueText(for routine: Routine) -> String {
        guard let baseDate = routine.lastLogDate else { return "No logs yet" }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: baseDate, to: Date())
        let months = max(0, components.month ?? 0)
        let days = max(0, components.day ?? 0)
        var parts: [String] = []
        if months > 0 {
            parts.append("\(months) \(months == 1 ? "mth" : "mths")")
        }
        if days > 0 || parts.isEmpty {
            parts.append("\(days) \(days == 1 ? "day" : "days")")
        }
        return parts.joined(separator: ", ")
    }
}

struct PastDueWidgetEntryView: View {
    var entry: PastDueProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(entry.routines) { routine in
                HStack(spacing: 12) {
                    Text(routine.emoji)
                        .font(.title2)
                    
                    Text(routine.overdueText)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(intent: LogRoutineEventIntent(routineID: routine.id.uuidString)) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            Spacer(minLength: 0)
            
            HStack {
                Image(systemName: "sunrise")
                Spacer()
                Text("\(entry.totalCount) Past Due")
                    .font(.subheadline)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

@main
struct PastDueWidget: Widget {
    let kind: String = WidgetKinds.pastDue
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PastDueProvider()) { entry in
            PastDueWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Past Due Routines")
        .description("Shows your past due routines.")
        .supportedFamilies([.systemMedium])
    }
}
