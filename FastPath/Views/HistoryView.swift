//
//  HistoryView.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

struct HistoryView: View {
    let store: StoreOf<FastingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.fastingHistory) { record in
                    FastingHistoryRow(record: record)
                }
                
                if viewStore.fastingHistory.isEmpty {
                    Text("No fasting records yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Fasting History")
            .listStyle(.insetGrouped)
        }
    }
}

struct FastingHistoryRow: View {
    let record: FastingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(formatDate(record.startTime))
                    .font(.headline)
                
                Spacer()
                
                Text(formatDuration(record))
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Started:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatTime(record.startTime))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Ended:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let endTime = record.endTime {
                        Text(formatTime(endTime))
                            .font(.subheadline)
                    } else {
                        Text("Active")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    // Helper functions for formatting
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ record: FastingRecord) -> String {
        guard let endTime = record.endTime else {
            return "In progress"
        }
        
        let duration = endTime.timeIntervalSince(record.startTime)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        
        return formatter.string(from: duration) ?? "Unknown"
    }
}

#Preview {
    NavigationStack {
        HistoryView(
            store: Store(
                initialState: FastingFeature.State(
                    fastingHistory: [
                        FastingRecord(
                            startTime: Date().addingTimeInterval(-86400),
                            endTime: Date().addingTimeInterval(-50000)
                        ),
                        FastingRecord(
                            startTime: Date().addingTimeInterval(-172800),
                            endTime: Date().addingTimeInterval(-150000)
                        )
                    ]
                ),
                reducer: { FastingFeature() }
            )
        )
    }
}
