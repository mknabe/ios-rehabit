//
//  HabitLog.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
class HabitLog {
    @Attribute(.unique) var id: UUID
    var loggedAt: Date
    var additionalInfo: String?
    
    var habit: Habit?
    
    init(loggedAt: Date = Date(), additionalInfo: String? = nil) {
        self.id = UUID()
        self.loggedAt = loggedAt
        self.additionalInfo = additionalInfo
    }
}
