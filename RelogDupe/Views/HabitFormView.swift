//
//  HabitFormView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitFormView: View {
    let habit: Habit?
    private let isEditing: Bool

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [HabitCategory]
    
    @State private var name: String
    @State private var emoji: String
    @State private var habitDescription: String
    @State private var selectedCategory: HabitCategory?
    @State private var showInUpcoming: Bool
    @State private var upcomingInterval: UpcomingReminderInterval
    @State private var upcomingDuration: Int
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

    init(habit: Habit? = nil) {
        self.habit = habit
        self.isEditing = habit != nil
        _name = State(initialValue: habit?.name ?? "")
        _emoji = State(initialValue: habit?.emoji ?? Self.randomEmoji())
        _habitDescription = State(initialValue: habit?.habitDescription ?? "")
        _selectedCategory = State(initialValue: habit?.category)
        _showInUpcoming = State(initialValue: habit?.upcomingReminder != nil)
        _upcomingInterval = State(initialValue: habit?.upcomingReminder?.interval ?? .month)
        _upcomingDuration = State(initialValue: habit?.upcomingReminder?.duration ?? 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Habit Name", text: $name)
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
                    TextEditor(text: $habitDescription)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
                }
                
                Section {
                    Toggle("Show in Upcoming Tab", isOn: $showInUpcoming)
                    
                    if showInUpcoming {
                        HStack {
                            Text("After")
                            Spacer()
                            TextField("", value: $upcomingDuration, formatter: Self.durationFormatter)
                                .frame(width: 48)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: upcomingDuration) { _, newValue in
                                    if newValue < 1 {
                                        upcomingDuration = 1
                                    }
                                }
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            Picker("", selection: $upcomingInterval) {
                                ForEach(UpcomingReminderInterval.allCases) { interval in
                                    Text(intervalLabel(for: interval)).tag(interval)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                        
                        Text("This habit will appear in the Upcoming Tab if it hasn't been completed after \(upcomingSummary).")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section() {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as HabitCategory?)
                        ForEach(categories) { category in
                            if let categoryName = category.name {
                                Text(categoryName).tag(category as HabitCategory?)
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
            .navigationTitle(isEditing ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHabit()
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
    
    private func saveHabit() {
        let normalizedDuration = max(1, upcomingDuration)
        if let habit {
            habit.name = name
            habit.emoji = emoji
            habit.habitDescription = habitDescription.isEmpty ? nil : habitDescription
            habit.category = selectedCategory
            if showInUpcoming {
                if let reminder = habit.upcomingReminder {
                    reminder.interval = upcomingInterval
                    reminder.duration = normalizedDuration
                } else {
                    habit.upcomingReminder = UpcomingReminder(
                        interval: upcomingInterval,
                        duration: normalizedDuration
                    )
                }
            } else {
                habit.upcomingReminder = nil
            }
        } else {
            let habit = Habit(
                name: name,
                emoji: emoji,
                description: habitDescription.isEmpty ? nil : habitDescription,
                category: selectedCategory,
                upcomingReminder: showInUpcoming
                    ? UpcomingReminder(interval: upcomingInterval, duration: normalizedDuration)
                    : nil
            )
            modelContext.insert(habit)
        }
        
        #if os(iOS) && !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        dismiss()
    }
    
    private func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        let newCategory = HabitCategory(name: newCategoryName)
        modelContext.insert(newCategory)
        selectedCategory = newCategory
        newCategoryName = ""
    }
    
    private var upcomingSummary: String {
        let intervalName = upcomingInterval.displayName
        let label = upcomingDuration == 1 ? intervalName : "\(intervalName)s"
        return "\(upcomingDuration) \(label)"
    }
    
    private func intervalLabel(for interval: UpcomingReminderInterval) -> String {
        let base = interval.displayName
        return upcomingDuration == 1 ? base : "\(base)s"
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
    HabitFormView()
        .modelContainer(PreviewContainer.shared.container)
}
