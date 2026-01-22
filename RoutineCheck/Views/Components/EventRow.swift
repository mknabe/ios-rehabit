//
//  EventRow.swift
//  RoutineCheck
//
//  Created by Maria Knabe on 1/5/26.
//

import SwiftUI
import SwiftData
import RoutineCheckShared

struct EventRow: View {
    let event: RoutineEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(event.loggedAt, format: .dateTime.day().month().year().hour().minute())
                .font(.headline)
            
            if let info = event.additionalInfo, !info.isEmpty {
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
        EventRow(event: RoutineEvent(loggedAt: Date(), additionalInfo: "Felt great today!"))
        EventRow(event: RoutineEvent(loggedAt: Date().addingTimeInterval(-3600)))
    }
    .modelContainer(PreviewContainer.shared.container)
}
