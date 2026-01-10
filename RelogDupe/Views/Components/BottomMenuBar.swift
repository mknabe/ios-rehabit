//
//  BottomMenuBar.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/10/26.
//

import SwiftUI

struct BottomMenuBar: View {
    enum Item {
        case upcoming
        case habits
        case log
    }
    
    let selected: Item
    let onUpcoming: () -> Void
    let onHabits: () -> Void
    let onLog: () -> Void
    
    var body: some View {
        HStack(spacing: 28) {
            menuButton(
                title: "Upcoming",
                systemImage: "calendar.badge.clock",
                isSelected: selected == .upcoming,
                action: onUpcoming
            )
            
            menuButton(
                title: "Habits",
                systemImage: "checkmark.circle",
                isSelected: selected == .habits,
                action: onHabits
            )
            
            menuButton(
                title: "Log",
                systemImage: "calendar.badge.plus",
                isSelected: selected == .log,
                action: onLog
            )
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private func menuButton(
        title: String,
        systemImage: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(isSelected ? Color.accentColor : .secondary)
        }
        .disabled(isSelected)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomMenuBar(
            selected: .upcoming,
            onUpcoming: {},
            onHabits: {},
            onLog: {}
        )
    }
    .padding(.bottom, 20)
}
