//
//  HabitFormView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var categories: [HabitCategory]
    
    @State private var name = ""
    @State private var emoji = Self.randomEmoji()
    @State private var habitDescription = ""
    @State private var selectedCategory: HabitCategory?
    @State private var showingAddCategory = false
    @State private var showingEmojiPicker = false
    @State private var newCategoryName = ""
    @FocusState private var focusedField: Field?
    @FocusState private var isCategoryNameFocused: Bool
    
    enum Field {
        case emoji, name, description
    }

    private static let emojiOptions = ["🌟", "🎯", "💪", "🧠", "📚", "☀️", "🌈", "🪴", "🧘‍♀️"]

    private static func randomEmoji() -> String {
        emojiOptions.randomElement() ?? "⭐️"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Emoji")
                        Spacer()
                        Button {
                            showingEmojiPicker = true
                        } label: {
                            Text(emoji.isEmpty ? "🙂" : emoji)
                                .font(.system(size: 32))
                                .frame(width: 50, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.08))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Choose emoji")
                    }
                    .listRowBackground(
                        emoji.isEmpty ? Color.red.opacity(0.1) : Color.clear
                    )
                    
                    // Name field
                    TextField("Habit Name", text: $name)
                        .focused($focusedField, equals: .name)
                }
                
                Section("Description") {
                    TextEditor(text: $habitDescription)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
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
                focusedField = .name
            }
            .navigationTitle("New Habit")
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
        let habit = Habit(
            name: name,
            emoji: emoji,
            description: habitDescription.isEmpty ? nil : habitDescription,
            category: selectedCategory
        )
        modelContext.insert(habit)
        
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
