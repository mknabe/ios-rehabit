//
//  PreviewContainer.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import RoutineCheckShared
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
            
            let category1 = RoutineCategory(name: "Health")
            let category2 = RoutineCategory(name: "Productivity")
            context.insert(category1)
            context.insert(category2)
            
            let routine1 = Routine(name: "Morning Run", emoji: "🏃", description: "30 minutes cardio", category: category1)
            let routine2 = Routine(name: "Read", emoji: "📚", description: "Read for 20 minutes", category: category2)
            let routine3 = Routine(name: "Meditation", emoji: "🧘", category: category1)
            context.insert(routine1)
            context.insert(routine2)
            context.insert(routine3)
            
            // Add some events
            let event1 = RoutineEvent(loggedAt: Date().addingTimeInterval(-3600), additionalInfo: "Felt great!")
            event1.routine = routine1
            context.insert(event1)
            
            let event2 = RoutineEvent(loggedAt: Date().addingTimeInterval(-7200), additionalInfo: "Finished chapter 5")
            event2.routine = routine2
            context.insert(event2)
            
            let event3 = RoutineEvent(loggedAt: Date(), additionalInfo: "10 minutes of breathing exercises")
            event3.routine = routine3
            context.insert(event3)
            
            try context.save()
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
