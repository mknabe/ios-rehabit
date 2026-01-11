//
//  PreviewContainer.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import RelogShared
import Foundation

@MainActor
class PreviewContainer {
    static let shared = PreviewContainer()
    
    let container: ModelContainer
    
    init() {
        do {
            container = try SharedModelContainer.makeContainer(inMemory: true)
            
            // Add sample data
            let context = container.mainContext
            
            let category1 = HabitCategory(name: "Health")
            let category2 = HabitCategory(name: "Productivity")
            context.insert(category1)
            context.insert(category2)
            
            let habit1 = Habit(name: "Morning Run", emoji: "🏃", description: "30 minutes cardio", category: category1)
            let habit2 = Habit(name: "Read", emoji: "📚", description: "Read for 20 minutes", category: category2)
            let habit3 = Habit(name: "Meditation", emoji: "🧘", category: category1)
            context.insert(habit1)
            context.insert(habit2)
            context.insert(habit3)
            
            // Add some logs
            let log1 = HabitLog(loggedAt: Date().addingTimeInterval(-3600), additionalInfo: "Felt great!")
            log1.habit = habit1
            context.insert(log1)
            
            let log2 = HabitLog(loggedAt: Date().addingTimeInterval(-7200), additionalInfo: "Finished chapter 5")
            log2.habit = habit2
            context.insert(log2)
            
            let log3 = HabitLog(loggedAt: Date(), additionalInfo: "10 minutes of breathing exercises")
            log3.habit = habit3
            context.insert(log3)
            
            try context.save()
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
