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
    @State private var emoji = ""
    @State private var habitDescription = ""
    @State private var selectedCategory: HabitCategory?
    @State private var showingAddCategory = false
    @State private var showingEmojiPicker = false
    @State private var newCategoryName = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case emoji, name, description
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Emoji picker button
                    HStack {
                        Text("Emoji")
                        Spacer()
                        
                        if emoji.isEmpty {
                            Button {
                                showingEmojiPicker = true
                            } label: {
                                Text("Tap to choose")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Button {
                                showingEmojiPicker = true
                            } label: {
                                Text(emoji)
                                    .font(.system(size: 40))
                            }
                        }
                    }
                    
                    // Name field
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
                    
                    // Quick add category button
                    Button {
                        showingAddCategory = true
                    } label: {
                        Label("Add New Category", systemImage: "plus.circle")
                    }
                }
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
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerSheet(selectedEmoji: $emoji, isPresented: $showingEmojiPicker)
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

// Native emoji keyboard sheet
struct EmojiPickerSheet: View {
    @Binding var selectedEmoji: String
    @Binding var isPresented: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Choose an emoji for your habit")
                    .font(.headline)
                    .padding(.top)
                
                TextField("", text: $selectedEmoji)
                    .font(.system(size: 100))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .onChange(of: selectedEmoji) { oldValue, newValue in
                        // Extract only the first emoji
                        if let firstEmoji = newValue.first(where: { $0.isEmoji }) {
                            selectedEmoji = String(firstEmoji)
                            isPresented = false
                        }
                    }
                    #if os(iOS)
                    .keyboardType(.default)
                    .autocorrectionDisabled()
                    #endif
                
                Text("Tap the keyboard icon to select an emoji")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .navigationTitle("Select Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                // Small delay to ensure keyboard shows
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocused = true
                }
            }
        }
        #if os(iOS)
        .presentationDetents([.medium])
        #endif
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
