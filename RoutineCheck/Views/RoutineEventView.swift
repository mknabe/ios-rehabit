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
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var logDate = Date()
    @State private var additionalInfo = ""
    @FocusState private var isNotesFieldFocused: Bool
    
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
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log Event") {
                        logEvent()
                    }
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
    
    private func logEvent() {
        let log = RoutineEvent(
            loggedAt: logDate,
            additionalInfo: additionalInfo.isEmpty ? nil : additionalInfo
        )
        log.routine = routine
        modelContext.insert(log)
        
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
