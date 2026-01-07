//
//  HabitDetailView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitDetailView: View {
    let habit: Habit
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingLogSheet = false
    @State private var showingEditSheet = false
    
    var sortedLogs: [HabitLog] {
        (habit.logs ?? []).sorted(by: { $0.loggedAt > $1.loggedAt })
    }
    
    var body: some View {
        List {
            if sortedLogs.isEmpty {
                ContentUnavailableView(
                    "No Logs Yet",
                    systemImage: "calendar.badge.clock",
                    description: Text("Tap the button to log this habit")
                )
            } else {
                ForEach(sortedLogs) { log in
                    LogRow(log: log)
                }
                .onDelete(perform: deleteLogs)
            }
        }
        .navigationTitle(habit.emoji + " " + habit.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Habit", systemImage: "pencil")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if !sortedLogs.isEmpty {
                    EditButton()
                }
            }
            #else
            ToolbarItem {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
            #endif

            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingLogSheet = true
                } label: {
                    Label("Log Habit", systemImage: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingLogSheet) {
            LogHabitView(habit: habit)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingEditSheet) {
            HabitFormView(habit: habit)
        }
        #if os(iOS)
        .overlay(alignment: .bottomTrailing) {
            // Floating action button for iOS
            if !sortedLogs.isEmpty {
                Button {
                    showingLogSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.blue)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        #endif
    }
    
    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedLogs[index])
        }
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
}

#Preview {
    NavigationStack {
        HabitDetailView(habit: Habit(name: "Morning Run", emoji: "🏃"))
    }
    .modelContainer(PreviewContainer.shared.container)
}
