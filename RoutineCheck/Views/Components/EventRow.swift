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
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(event.loggedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.headline)
                
                if let info = event.additionalInfo, !info.isEmpty {
                    Text(info)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 8)
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .padding(.top, 2)
        }
    }
}

#Preview {
    List {
        EventRow(event: RoutineEvent(loggedAt: Date(), additionalInfo: "Felt great today!"))
        EventRow(event: RoutineEvent(loggedAt: Date().addingTimeInterval(-3600)))
    }
    .modelContainer(PreviewContainer.shared.container)
}
