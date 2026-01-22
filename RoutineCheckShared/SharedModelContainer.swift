//
//  SharedModelContainer.swift
//  RelogShared
//
//  Created by Maria Knabe on 1/10/26.
//

import Foundation
import SwiftData

public enum SharedModelContainer {
    public static let appGroupID = "group.com.mknabe.RoutineCheck"
    
    public static let schema = Schema([
        Routine.self,
        RoutineEvent.self,
        RoutineCategory.self,
        RoutineReminder.self
    ])
    
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        if inMemory {
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [configuration])
        }
        
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            throw SharedModelContainerError.appGroupMissing
        }
        
        let storeURL = containerURL.appendingPathComponent("RoutineCheck.store")
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

public enum SharedModelContainerError: Error {
    case appGroupMissing
}
