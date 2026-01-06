//
//  EmptyStateView.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "checklist",
        title: "No Habits Yet",
        message: "Tap + to create your first habit"
    )
}
