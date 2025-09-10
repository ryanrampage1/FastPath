//
//  StartTimeEditorView.swift
//  FastPath
//
//  Created on 5/6/25.
//

import SwiftUI
import ComposableArchitecture

struct StartTimeEditorView: View {
    let store: StoreOf<FastingFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: 20) {
                    Text("Adjust Start Time")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Select a new start time for your current fast")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    if let editingTime = viewStore.editingStartTime {
                        DatePicker(
                            "Start Time",
                            selection: viewStore.binding(
                                get: { _ in editingTime },
                                send: { .updateStartTime($0) }
                            ),
                            in: ...Date(),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                    }
                    
                    Spacer()
                    
                    Text("Note: The new start time cannot be in the future")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom)
                }
                .navigationBarTitle("Edit Start Time", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        viewStore.send(.startTimeEditorDismissed)
                    },
                    trailing: Button("Save") {
                        if let time = viewStore.editingStartTime {
                            viewStore.send(.updateStartTime(time))
                        }
                    }
                    .disabled(viewStore.editingStartTime == nil)
                )
            }
        }
    }
}

#Preview {
    StartTimeEditorView(
        store: Store(
            initialState: FastingFeature.State(
                editingStartTime: Date().addingTimeInterval(-3600)
            ),
            reducer: { FastingFeature() }
        )
    )
}
