//
//  LogHabitIntent.swift
//  UpcomingWidget
//
//  Created by Maria Knabe on 1/10/26.
//

import AppIntents
import SwiftData
import RelogShared

struct LogHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Habit"
    static let description = IntentDescription("Logs a habit right now.")
    
    @Parameter(title: "Habit ID")
    var habitID: String
    
    static let openAppWhenRun = false

    init() {}

    init(habitID: String) {
        self.habitID = habitID
    }
    
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: habitID) else {
            return .result()
        }
        
        let container = try SharedModelContainer.makeContainer()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Habit>(predicate: #Predicate { $0.id == id })
        
        if let habit = try context.fetch(descriptor).first {
            let log = HabitLog(loggedAt: Date())
            log.habit = habit
            context.insert(log)
            try context.save()
        }
        
        return .result()
    }
}
