//
//  LogRow.swift
//  RelogDupe
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RelogShared

struct LogRow: View {
    let log: HabitLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(log.loggedAt, format: .dateTime.day().month().year().hour().minute())
                .font(.headline)
            
            if let info = log.additionalInfo, !info.isEmpty {
                Text(info)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        LogRow(log: HabitLog(loggedAt: Date(), additionalInfo: "Felt great today!"))
        LogRow(log: HabitLog(loggedAt: Date().addingTimeInterval(-3600)))
    }
    .modelContainer(PreviewContainer.shared.container)
}
