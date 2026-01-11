//
//  RootTabsView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import SwiftData
import RelogShared

struct RootTabsView: View {
    enum Item {
        case upcoming
        case habits
        case log
    }
    
    
    @Query(sort: \Habit.createdAt, order: .reverse) private var habits: [Habit]
    @State private var selected: Item = .habits
    
    private var upcomingCount: Int {
        habits.filter { $0.isUpcomingDue }.count
    }
    
    var body: some View {
        TabView(selection: $selected) {
            UpcomingView()
                .tag(Item.upcoming)
                .tabItem {
                    Label("Upcoming", systemImage: "calendar.badge.clock")
                }
                .modifier(UpcomingBadge(count: upcomingCount))
            
            HabitsListView()
                .tag(Item.habits)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
        }
    }
    
}

private struct UpcomingBadge: ViewModifier {
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
