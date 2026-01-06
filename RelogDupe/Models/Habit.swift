//
//  Habit.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var emoji: String
    var habitDescription: String?
    var createdAt: Date
    
    var category: HabitCategory?
    
    @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
    var logs: [HabitLog]?
    
    init(name: String, emoji: String, description: String? = nil, category: HabitCategory? = nil) {
        self.id = UUID()
        self.name = name
        self.emoji = emoji
        self.habitDescription = description
        self.category = category
        self.createdAt = Date()
    }
    
    // Computed property for last log date
    var lastLogDate: Date? {
        logs?.sorted(by: { $0.loggedAt > $1.loggedAt }).first?.loggedAt
    }
    
    // Computed property for total log count
    var totalLogs: Int {
        logs?.count ?? 0
    }
}
