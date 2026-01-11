//
//  UpcomingWidget.swift
//  UpcomingWidget
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import WidgetKit
import SwiftData
import RelogShared

struct UpcomingEntry: TimelineEntry {
    let date: Date
    let habits: [UpcomingHabitEntry]
    let totalCount: Int
}

struct UpcomingHabitEntry: Identifiable {
    let id: UUID
    let emoji: String
    let name: String
    let overdueText: String
}

struct UpcomingProvider: TimelineProvider {
    func placeholder(in context: Context) -> UpcomingEntry {
        UpcomingEntry(
            date: Date(),
            habits: [
                UpcomingHabitEntry(id: UUID(), emoji: "✂️", name: "Trim Hair", overdueText: "9 mths, 9 days")
            ],
            totalCount: 1
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (UpcomingEntry) -> Void) {
        completion(loadEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<UpcomingEntry>) -> Void) {
        let entry = loadEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func loadEntry() -> UpcomingEntry {
        do {
            let container = try SharedModelContainer.makeContainer()
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Habit>()
            let habits = try context.fetch(descriptor)
            let upcoming = habits
                .filter { $0.isUpcomingDue }
                .sorted { ($0.upcomingDueDate ?? .distantPast) < ($1.upcomingDueDate ?? .distantPast) }
            
            let entries = upcoming.prefix(3).map { habit in
                UpcomingHabitEntry(
                    id: habit.id,
                    emoji: habit.emoji,
                    name: habit.name,
                    overdueText: overdueText(for: habit)
                )
            }
            
            return UpcomingEntry(
                date: Date(),
                habits: entries,
                totalCount: upcoming.count
            )
        } catch {
            return UpcomingEntry(date: Date(), habits: [], totalCount: 0)
        }
    }
    
    private func overdueText(for habit: Habit) -> String {
        guard let baseDate = habit.lastLogDate else { return "No logs yet" }
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

struct UpcomingWidgetEntryView: View {
    var entry: UpcomingProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(entry.habits) { habit in
                HStack(spacing: 12) {
                    Text(habit.emoji)
                        .font(.title2)
                    
                    Text(habit.overdueText)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(intent: LogHabitIntent(habitID: habit.id.uuidString)) {
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
                Text("\(entry.totalCount) Upcoming")
                    .font(.subheadline)
            }
        }
        .padding()
    }
}

@main
struct UpcomingWidget: Widget {
    let kind: String = WidgetKinds.upcoming
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: UpcomingProvider()) { entry in
            UpcomingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming Habits")
        .description("Shows your most overdue upcoming habits.")
        .supportedFamilies([.systemMedium])
    }
}
