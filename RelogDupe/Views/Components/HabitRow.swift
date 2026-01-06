//
//  HabitRow.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct HabitRow: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji
            Text(habit.emoji)
                .font(.system(size: 40))
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                // Habit name
                Text(habit.name)
                    .font(.headline)
                
                // Last logged time
                if let lastLog = habit.lastLogDate {
                    Text("Last logged \(lastLog, style: .relative)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not logged yet")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                
                // Category badge
                if let category = habit.category, let categoryName = category.name {
                    Text(categoryName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(habit.emoji) \(habit.name)")
        .accessibilityHint("Tap to view logs")
        .accessibilityValue(habit.lastLogDate != nil ? "Last logged \(habit.lastLogDate!, style: .relative)" : "Not logged yet")
    }
}

#Preview {
    List {
        HabitRow(habit: Habit(name: "Morning Run", emoji: "🏃", description: "30 min cardio"))
        HabitRow(habit: Habit(name: "Read", emoji: "📚"))
    }
    .modelContainer(PreviewContainer.shared.container)
}
