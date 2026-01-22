//
//  LogRoutineEventIntent.swift
//  PastDueWidget
//
//  Created by Maria Knabe on 1/10/26.
//

import AppIntents
import SwiftData
import RoutineCheckShared

struct LogRoutineEventIntent: AppIntent {
    static let title: LocalizedStringResource = "Log Routine"
    static let description = IntentDescription("Logs a routine right now.")
    
    @Parameter(title: "Routine ID")
    var routineID: String
    
    static let openAppWhenRun = false

    init() {}

    init(routineID: String) {
        self.routineID = routineID
    }
    
    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: routineID) else {
            return .result()
        }
        
        let container = try SharedModelContainer.makeContainer()
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<Routine>(predicate: #Predicate { $0.id == id })
        
        if let routine = try context.fetch(descriptor).first {
            let log = RoutineEvent(loggedAt: Date())
            log.routine = routine
            context.insert(log)
            try context.save()
        }
        
        return .result()
    }
}
