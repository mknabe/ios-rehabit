//
//  HabitCategory.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
public class HabitCategory {
    @Attribute(.unique) public var id: UUID
    public var name: String?
    public var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Habit.category)
    public var habits: [Habit]?
    
    public init(name: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
