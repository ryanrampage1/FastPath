//
//  GoalPickerView.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

struct GoalPickerView: View {
    let store: StoreOf<FastingFeature>
    @State private var customHours: Double = 16
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section(header: Text("Predefined Fasting Goals")) {
                        ForEach(FastingGoal.predefinedGoals, id: \.targetDuration) { goal in
                            Button {
                                viewStore.send(.selectPredefinedGoal(goal))
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(goal.name ?? "")
                                            .font(.headline)
                                        
                                        if let description = goal.description {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(formatDuration(goal.targetDuration))
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Section(header: Text("Custom Goal")) {
                        VStack {
                            HStack {
                                Text("Duration: \(Int(customHours)) hours")
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button {
                                    viewStore.send(.setCustomGoal(customHours * 3600))
                                } label: {
                                    Text("Set")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.blue)
                                        )
                                }
                            }
                            
                            Slider(value: $customHours, in: 1...36, step: 1)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    if viewStore.fastingGoal != nil {
                        Section {
                            Button {
                                viewStore.send(.clearGoal)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Clear Current Goal")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Set Fasting Goal")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            viewStore.send(.goalPickerDismissed)
                        }
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)m"
        }
    }
}

#Preview {
    GoalPickerView(
        store: Store(
            initialState: FastingFeature.State(
                fastingGoal: FastingGoal.predefinedGoals[1]
            ),
            reducer: { FastingFeature() }
        )
    )
}
