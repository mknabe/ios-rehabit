//
//  HabitsListView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddHabit = false
    @State private var searchText = ""
    
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
                                HabitRow(habit: habit)
                            }
                        }
                        .onDelete(perform: deleteHabits)
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
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !habits.isEmpty {
                        EditButton()
                    }
                }
                #endif
                
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
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredHabits[index])
        }
    }
}

#Preview {
    HabitsListView()
        .modelContainer(PreviewContainer.shared.container)
}
