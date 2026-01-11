//
//  HabitLog.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
public class HabitLog {
    @Attribute(.unique) public var id: UUID
    public var loggedAt: Date
    public var additionalInfo: String?
    
    public var habit: Habit?
    
    public init(loggedAt: Date = Date(), additionalInfo: String? = nil) {
        self.id = UUID()
        self.loggedAt = loggedAt
        self.additionalInfo = additionalInfo
    }
}
