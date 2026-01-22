//
//  RootTabsView.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared

struct RootTabsView: View {
    enum Item {
        case pastDue
        case routines
        case log
    }
    
    
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @State private var selected: Item = .routines
    
    private var pastDueCount: Int {
        routines.filter { $0.isPastDue }.count
    }
    
    var body: some View {
        TabView(selection: $selected) {
            PastDueView()
                .tag(Item.pastDue)
                .tabItem {
                    Label("Past Due", systemImage: "calendar.badge.clock")
                }
                .modifier(PastDueBadge(count: pastDueCount))
            
            RoutinesListView()
                .tag(Item.routines)
                .tabItem {
                    Label("Routines", systemImage: "checkmark.circle")
                }
        }
    }
    
}

private struct PastDueBadge: ViewModifier {
    let count: Int
    
    func body(content: Content) -> some View {
        if count > 0 {
            content.badge(count)
        } else {
            content
        }
    }
}

#Preview {
    RootTabsView()
        .modelContainer(PreviewContainer.shared.container)
}
