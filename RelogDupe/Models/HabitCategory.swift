//
//  HabitCategory.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
class HabitCategory {
    @Attribute(.unique) var id: UUID
    var name: String?
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Habit.category)
    var habits: [Habit]?
    
    init(name: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
