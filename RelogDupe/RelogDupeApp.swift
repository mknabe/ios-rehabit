//
//  RelogDupeApp.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RelogShared

@main
struct RelogDupeApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try SharedModelContainer.makeContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
