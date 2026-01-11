//
//  HabitsListView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RelogShared
#if canImport(WidgetKit)
import WidgetKit
#endif

struct HabitsListView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddHabit = false
    @State private var searchText = ""
    @State private var habitToLog: Habit?
    
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return habits
        }
        return habits.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No Habits Yet",
                        message: "Tap + to create your first habit"
                    )
                } else {
                    List {
                        ForEach(filteredHabits) { habit in
                            NavigationLink(value: habit) {
                                HabitRow(habit: habit, onEmojiTap: {
                                    logHabitNow(habit)
                                })
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
                    .searchable(text: $searchText, prompt: "Search habits")
                }
            }
            .navigationTitle("Habits")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                HabitFormView()
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
}

#Preview {
    HabitsListView()
        .modelContainer(PreviewContainer.shared.container)
}
