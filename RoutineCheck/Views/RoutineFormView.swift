//
//  RoutineFormView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared

struct RoutineFormView: View {
    let routine: Routine?
    private let isEditing: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [RoutineCategory]
    
    @State private var name: String
    @State private var emoji: String
    @State private var routineDescription: String
    @State private var selectedCategory: RoutineCategory?
    @State private var showInPastDue: Bool
    @State private var reminderInterval: ReminderInterval
    @State private var reminderDuration: Int
    @State private var showingAddCategory = false
    @State private var showingEmojiPicker = false
    @State private var newCategoryName = ""
    @FocusState private var focusedField: Field?
    @FocusState private var isCategoryNameFocused: Bool
    
    enum Field {
        case emoji, name, description
    }

    private static let emojiOptions = ["🌟", "🎯", "💪", "🧠", "📚", "☀️", "🌈", "🪴", "🧘‍♀️"]
    private static let durationFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.allowsFloats = false
        return formatter
    }()

    private static func randomEmoji() -> String {
        emojiOptions.randomElement() ?? "⭐️"
    }

    init(routine: Routine? = nil) {
        self.routine = routine
        self.isEditing = routine != nil
        _name = State(initialValue: routine?.name ?? "")
        _emoji = State(initialValue: routine?.emoji ?? Self.randomEmoji())
        _routineDescription = State(initialValue: routine?.routineDescription ?? "")
        _selectedCategory = State(initialValue: routine?.category)
        _showInPastDue = State(initialValue: routine?.reminder != nil)
        _reminderInterval = State(initialValue: routine?.reminder?.interval ?? .month)
        _reminderDuration = State(initialValue: routine?.reminder?.duration ?? 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Routine Name", text: $name)
                        .focused($focusedField, equals: .name)
                    
                    HStack {
                        Text("Icon")
                        Spacer()
                        Text(emoji)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .background(Color.white)
                    .onTapGesture {
                        showingEmojiPicker = true
                    }
                    .accessibilityLabel("Choose emoji")
                    .accessibilityAddTraits(.isButton)
                }
                
                Section("Description") {
                    TextEditor(text: $routineDescription)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
                }
                
                Section {
                    Toggle("Show in Past Due Tab", isOn: $showInPastDue)
                    
                    if showInPastDue {
                        HStack {
                            Text("After")
                            Spacer()
                            TextField("", value: $reminderDuration, formatter: Self.durationFormatter)
                                .frame(width: 48)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: reminderDuration) { _, newValue in
                                    if newValue < 1 {
                                        reminderDuration = 1
                                    }
                                }
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            Picker("", selection: $reminderInterval) {
                                ForEach(ReminderInterval.allCases) { interval in
                                    Text(intervalLabel(for: interval)).tag(interval)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        
                        Text("This routine will appear in the Past Due Tab if it hasn't been completed after \(reminderSummary).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section() {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as RoutineCategory?)
                        ForEach(categories) { category in
                            if let categoryName = category.name {
                                Text(categoryName).tag(category as RoutineCategory?)
                            }
                        }
                    }
                    
                    // Quick add category button
                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Add New Category", systemImage: "plus.circle")
                    }
                }
            }
            .onAppear {
                if !isEditing {
                    focusedField = .name
                }
            }
            .navigationTitle(isEditing ? "Edit Routine" : "New Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .disabled(name.isEmpty || emoji.isEmpty)
                }
                
                #if os(iOS)
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
                #endif
            }
            .sheet(isPresented: $showingAddCategory) {
                NavigationStack {
                    Form {
                        TextField("Category name", text: $newCategoryName)
                            .textInputAutocapitalization(.words)
                            .focused($isCategoryNameFocused)
                    }
                    .navigationTitle("New Category")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                newCategoryName = ""
                                showingAddCategory = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                addNewCategory()
                                showingAddCategory = false
                            }
                            .disabled(newCategoryName.isEmpty)
                        }
                    }
                    .onAppear {
                        isCategoryNameFocused = true
                    }
                }
                .presentationDetents([.height(220)])
            }
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(selectedEmoji: $emoji)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func saveRoutine() {
        let normalizedDuration = max(1, reminderDuration)
        if let routine {
            routine.name = name
            routine.emoji = emoji
            routine.routineDescription = routineDescription.isEmpty ? nil : routineDescription
            routine.category = selectedCategory
            if showInPastDue {
                if let reminder = routine.reminder {
                    reminder.interval = reminderInterval
                    reminder.duration = normalizedDuration
                } else {
                    routine.reminder = RoutineReminder(
                        interval: reminderInterval,
                        duration: normalizedDuration
                    )
                }
            } else {
                routine.reminder = nil
            }
        } else {
            let routine = Routine(
                name: name,
                emoji: emoji,
                description: routineDescription.isEmpty ? nil : routineDescription,
                category: selectedCategory,
                reminder: showInPastDue
                    ? RoutineReminder(interval: reminderInterval, duration: normalizedDuration)
                    : nil
            )
            modelContext.insert(routine)
        }
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        dismiss()
    }
    
    private func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        let newCategory = RoutineCategory(name: newCategoryName)
        modelContext.insert(newCategory)
        selectedCategory = newCategory
        newCategoryName = ""
    }
    
    private var reminderSummary: String {
        let intervalName = reminderInterval.displayName
        let label = reminderDuration == 1 ? intervalName : "\(intervalName)s"
        return "\(reminderDuration) \(label)"
    }
    
    private func intervalLabel(for interval: ReminderInterval) -> String {
        let base = interval.displayName
        return reminderDuration == 1 ? base : "\(base)s"
    }
}

// Helper extension to check if a character is an emoji
extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

#Preview {
    RoutineFormView()
        .modelContainer(PreviewContainer.shared.container)
}
