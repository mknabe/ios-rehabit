//
//  RoutineEventView.swift
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

struct RoutineEventView: View {
    let routine: Routine
    let event: RoutineEvent?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var logDate: Date
    @State private var additionalInfo: String
    @FocusState private var isNotesFieldFocused: Bool
    
    init(routine: Routine, event: RoutineEvent? = nil) {
        self.routine = routine
        self.event = event
        _logDate = State(initialValue: event?.loggedAt ?? Date())
        _additionalInfo = State(initialValue: event?.additionalInfo ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When") {
                    DatePicker("When", selection: $logDate)
                }
                
                Section("Notes") {
                    TextEditor(text: $additionalInfo)
                        .frame(minHeight: 100)
                        .focused($isNotesFieldFocused)
                }
            }
            .navigationTitle("\(routine.emoji) \(routine.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Cancel")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveEvent()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel("Save")
                }
                
                #if os(iOS)
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            isNotesFieldFocused = false
                        }
                    }
                }
                #endif
            }
        }
    }
    
    private func saveEvent() {
        if let event {
            event.loggedAt = logDate
            event.additionalInfo = additionalInfo.isEmpty ? nil : additionalInfo
        } else {
            let log = RoutineEvent(
                loggedAt: logDate,
                additionalInfo: additionalInfo.isEmpty ? nil : additionalInfo
            )
            log.routine = routine
            modelContext.insert(log)
        }
        
        try? modelContext.save()
        
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetKinds.pastDue)
        #endif
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        dismiss()
    }
}

#Preview {
    RoutineEventView(routine: Routine(name: "Morning Run", emoji: "🏃"))
        .modelContainer(PreviewContainer.shared.container)
}
