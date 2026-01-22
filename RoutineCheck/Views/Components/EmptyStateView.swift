//
//  EmptyStateView.swift
//  RoutineCheck
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
        title: "No Routines Yet",
        message: "Tap + to create your first routine"
    )
}
