//
//  RoutineDetailView.swift
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

struct RoutineDetailView: View {
    let routine: Routine
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingLogSheet = false
    @State private var showingEditSheet = false
    @State private var editingEvent: RoutineEvent?
    
    var sortedEvents: [RoutineEvent] {
        (routine.logs ?? []).sorted(by: { $0.loggedAt > $1.loggedAt })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(routine.emoji + " " + routine.name)
                .font(.largeTitle.weight(.bold))
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGroupedBackground))

            List {
                if sortedEvents.isEmpty {
                    ContentUnavailableView(
                        "No Events Logged Yet",
                        systemImage: "calendar.badge.clock",
                        description: Text("Tap the button to log this routine")
                    )
                } else {
                    ForEach(sortedEvents) { log in
                        EventRow(event: log)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                editingEvent = log
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    deleteLog(log)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: deleteLogs)
                }
            }
            .padding(.top, 0)
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Routine", systemImage: "pencil")
                }
            }
            #else
            ToolbarItem {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
            #endif
        }
        .sheet(isPresented: $showingLogSheet) {
            RoutineEventView(routine: routine)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingEditSheet) {
            RoutineFormView(routine: routine)
        }
        .sheet(item: $editingEvent) { event in
            RoutineEventView(routine: routine, event: event)
                .presentationDetents([.medium])
        }
//        #if os(iOS)
        .overlay(alignment: .bottomTrailing) {
            // Floating action button for iOS
            Button {
                showingLogSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 56))
//                        .foregroundStyle(.blue)
//                        .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
//        #endif
    }
    
    private func deleteLogs(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedEvents[index])
        }
        try? modelContext.save()

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.pastDue)
        #endif
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    private func deleteLog(_ event: RoutineEvent) {
        modelContext.delete(event)
        try? modelContext.save()

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
    NavigationStack {
        RoutineDetailView(routine: Routine(name: "Morning Run", emoji: "🏃"))
    }
    .modelContainer(PreviewContainer.shared.container)
}
