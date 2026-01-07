//
//  LogHabitView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct LogHabitView: View {
    let habit: Habit
    
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
            .navigationTitle("\(habit.emoji) \(habit.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        saveLog()
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
    
    private func saveLog() {
        let log = HabitLog(
            loggedAt: logDate,
            additionalInfo: additionalInfo.isEmpty ? nil : additionalInfo
        )
        log.habit = habit
        modelContext.insert(log)
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        dismiss()
    }
}

#Preview {
    LogHabitView(habit: Habit(name: "Morning Run", emoji: "🏃"))
        .modelContainer(PreviewContainer.shared.container)
}
