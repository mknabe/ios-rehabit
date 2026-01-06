//
//  HabitEditView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitEditView: View {
    let habit: Habit

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var categories: [HabitCategory]

    @State private var name: String
    @State private var emoji: String
    @State private var habitDescription: String
    @State private var selectedCategory: HabitCategory?
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case emoji, name, description
    }

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _emoji = State(initialValue: habit.emoji)
        _habitDescription = State(initialValue: habit.habitDescription ?? "")
        _selectedCategory = State(initialValue: habit.category)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Emoji")
                        Spacer()
                        TextField("", text: $emoji)
                            .font(.system(size: 40))
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .onChange(of: emoji) { oldValue, newValue in
                                if let firstEmoji = newValue.first(where: { $0.isEmoji }) {
                                    emoji = String(firstEmoji)
                                }
                            }
                    }
                    .listRowBackground(
                        emoji.isEmpty ? Color.red.opacity(0.1) : Color.clear
                    )

                    TextField("Habit Name", text: $name)
                        .focused($focusedField, equals: .name)
                }

                Section("Description") {
                    TextEditor(text: $habitDescription)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as HabitCategory?)
                        ForEach(categories) { category in
                            if let categoryName = category.name {
                                Text(categoryName).tag(category as HabitCategory?)
                            }
                        }
                    }

                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Add New Category", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
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
            .alert("New Category", isPresented: $showingAddCategory) {
                TextField("Category name", text: $newCategoryName)
                Button("Cancel", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Add") {
                    addNewCategory()
                }
            } message: {
                Text("Enter a name for the new category")
            }
        }
    }

    private func saveChanges() {
        habit.name = name
        habit.emoji = emoji
        habit.habitDescription = habitDescription.isEmpty ? nil : habitDescription
        habit.category = selectedCategory

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
}

#Preview {
    HabitEditView(habit: Habit(name: "Morning Run", emoji: "🏃", description: "30 min cardio"))
        .modelContainer(PreviewContainer.shared.container)
}
