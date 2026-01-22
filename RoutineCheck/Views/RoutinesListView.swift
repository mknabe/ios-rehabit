//
//  RoutinesListView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared
#if canImport(WidgetKit)
import WidgetKit
#endif

struct RoutinesListView: View {
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddRoutine = false
    @State private var searchText = ""
    @State private var routineToLog: Routine?
    
    var filteredRoutines: [Routine] {
        if searchText.isEmpty {
            return routines
        }
        return routines.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if routines.isEmpty {
                    EmptyStateView(
                        icon: "checklist",
                        title: "No Routines Yet",
                        message: "Tap + to create your first routine"
                    )
                } else {
                    List {
                        ForEach(filteredRoutines) { routine in
                            NavigationLink(value: routine) {
                                RoutineRow(routine: routine, onEmojiTap: {
                                    logRoutineNow(routine)
                                })
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
                    .searchable(text: $searchText, prompt: "Search routines")
                }
            }
            .navigationTitle("Routines")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .navigationDestination(for: Routine.self) { routine in
                RoutineDetailView(routine: routine)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddRoutine = true
                    } label: {
                        Label("Add Routine", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRoutine) {
                RoutineFormView()
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
}

#Preview {
    RoutinesListView()
        .modelContainer(PreviewContainer.shared.container)
}
