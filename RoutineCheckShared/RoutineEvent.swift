//
//  RoutineEvent.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
public class RoutineEvent {
    @Attribute(.unique) public var id: UUID
    public var loggedAt: Date
    public var additionalInfo: String?
    
    public var routine: Routine?
    
    public init(loggedAt: Date = Date(), additionalInfo: String? = nil) {
        self.id = UUID()
        self.loggedAt = loggedAt
        self.additionalInfo = additionalInfo
    }
}
