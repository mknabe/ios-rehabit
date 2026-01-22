//
//  RoutineCategory.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftData
import Foundation

@Model
public class RoutineCategory {
    @Attribute(.unique) public var id: UUID
    public var name: String?
    public var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Routine.category)
    public var routines: [Routine]?
    
    public init(name: String? = nil) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()
    }
}
