//
//  RoutineRow.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared

struct RoutineRow: View {
    let routine: Routine
    let onEmojiTap: (() -> Void)?
    let secondaryText: String?

    init(routine: Routine, onEmojiTap: (() -> Void)? = nil, secondaryText: String? = nil) {
        self.routine = routine
        self.onEmojiTap = onEmojiTap
        self.secondaryText = secondaryText
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Emoji
            Group {
                if let onEmojiTap {
                    Button(action: onEmojiTap) {
                        Text(routine.emoji)
                            .font(.system(size: 40))
                            .frame(width: 50, height: 50)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Log \(routine.name)")
                    .accessibilityHint("Creates a new log with the current time")
                } else {
                    Text(routine.emoji)
                        .font(.system(size: 40))
                        .frame(width: 50, height: 50)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                
                // Last logged time
                if let secondaryText {
                    Text(secondaryText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let lastLog = routine.lastLogDate {
                    Text(lastLog, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Not logged yet")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                
                // Category badge
                if let category = routine.category, let categoryName = category.name {
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(routine.emoji) \(routine.name)")
        .accessibilityHint("Tap to view logs")
        .accessibilityValue(accessibilitySecondaryValue)
    }
    
    private var accessibilitySecondaryValue: String {
        if let secondaryText {
            return secondaryText
        }
        if let lastLog = routine.lastLogDate {
            return "Last logged \(Self.relativeFormatter.localizedString(for: lastLog, relativeTo: Date()))"
        }
        return "Not logged yet"
    }
    
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
}

#Preview {
    List {
        RoutineRow(routine: Routine(name: "Morning Run", emoji: "🏃", description: "30 min cardio"))
        RoutineRow(routine: Routine(name: "Read", emoji: "📚"))
    }
    .modelContainer(PreviewContainer.shared.container)
}
