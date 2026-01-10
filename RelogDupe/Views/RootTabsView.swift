//
//  RootTabsView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI
import SwiftData

struct RootTabsView: View {
    enum Item {
        case upcoming
        case habits
        case log
    }
    
    
    @State private var selected: Item = .habits
    
    var body: some View {
        TabView(selection: $selected) {
            HabitsListView()
                .tag(Item.habits)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle")
                }
            
            UpcomingView()
                .tag(Item.upcoming)
                .tabItem {
                    Label("Upcoming", systemImage: "calendar.badge.clock")
                }
        }
    }
}

#Preview {
    RootTabsView()
        .modelContainer(PreviewContainer.shared.container)
}
