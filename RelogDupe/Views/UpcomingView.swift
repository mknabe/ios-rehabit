//
//  UpcomingView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import SwiftData
import RelogShared
#if canImport(WidgetKit)
import WidgetKit
#endif

struct UpcomingView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var habitToLog: Habit?
    
    private var upcomingHabits: [Habit] {
        habits
            .filter { $0.isUpcomingDue }
            .sorted { ($0.upcomingDueDate ?? .distantPast) < ($1.upcomingDueDate ?? .distantPast) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if upcomingHabits.isEmpty {
                    ContentUnavailableView(
                        "No Upcoming Habits",
                        systemImage: "calendar.badge.clock",
                        description: Text("You're all caught up")
                    )
                } else {
                    List {
                        ForEach(upcomingHabits) { habit in
                            NavigationLink(value: habit) {
                                HabitRow(
                                    habit: habit,
                                    onEmojiTap: {
                                        logHabitNow(habit)
                                    },
                                    secondaryText: overdueText(for: habit)
                                )
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    habitToLog = habit
                                } label: {
                                    Label("Custom Log", systemImage: "calendar.badge.plus")
                                        .labelStyle(.iconOnly)
                                }
                                .tint(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Upcoming Tasks")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .sheet(item: $habitToLog) { habit in
                LogHabitView(habit: habit)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func logHabitNow(_ habit: Habit) {
        let log = HabitLog(loggedAt: Date())
        log.habit = habit
        modelContext.insert(log)
        
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.upcoming)
        #endif
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    private func overdueText(for habit: Habit) -> String {
        let baseDate = habit.lastLogDate ?? habit.createdAt
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour], from: baseDate, to: Date())
        let days = max(0, components.day ?? 0)
        let hours = max(0, components.hour ?? 0)
        var parts: [String] = []
        if days > 0 {
            parts.append("\(days) \(days == 1 ? "day" : "days")")
        }
        let hourLabel = hours == 1 ? "hr" : "hrs"
        if hours > 0 || parts.isEmpty {
            parts.append("\(hours) \(hourLabel)")
        }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    UpcomingView()
        .modelContainer(PreviewContainer.shared.container)
}
