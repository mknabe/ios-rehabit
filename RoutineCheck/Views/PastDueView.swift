//
//  PastDueView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared
#if canImport(WidgetKit)
import WidgetKit
#endif

struct PastDueView: View {
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    @State private var routineToLog: Routine?
    
    private var pastDueRoutines: [Routine] {
        routines
            .filter { $0.isPastDue }
            .sorted { ($0.pastDueDate ?? .distantPast) < ($1.pastDueDate ?? .distantPast) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if pastDueRoutines.isEmpty {
                    ContentUnavailableView(
                        "No Past Due Routines",
                        systemImage: "calendar.badge.clock",
                        description: Text("You're all caught up")
                    )
                } else {
                    List {
                        ForEach(pastDueRoutines) { routine in
                            NavigationLink(value: routine) {
                                RoutineRow(
                                    routine: routine,
                                    onEmojiTap: {
                                        logRoutineNow(routine)
                                    },
                                    secondaryText: overdueText(for: routine)
                                )
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    routineToLog = routine
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
            .navigationTitle("Past Due Routines")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .navigationDestination(for: Routine.self) { routine in
                RoutineDetailView(routine: routine)
            }
            .sheet(item: $routineToLog) { routine in
                RoutineEventView(routine: routine)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private func logRoutineNow(_ routine: Routine) {
        let log = RoutineEvent(loggedAt: Date())
        log.routine = routine
        modelContext.insert(log)
        
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.pastDue)
        #endif
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    private func overdueText(for routine: Routine) -> String {
        let baseDate = routine.lastLogDate ?? routine.createdAt
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
    PastDueView()
        .modelContainer(PreviewContainer.shared.container)
}
