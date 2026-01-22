//
//  ContentView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            RoutinesListView()
        } detail: {
            Text("Select a routine")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
        #else
        RootTabsView()
        #endif
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.shared.container)
}
