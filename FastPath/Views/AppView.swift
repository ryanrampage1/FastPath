//
//  AppView.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in // Observe the whole state or specific parts
            VStack { // Wrap existing content in a VStack
                // Display the inspirational message
                if let message = viewStore.currentInspirationalMessage, !message.isEmpty {
                    Text(message)
                        .padding() // Add some padding for better appearance
                        .font(.caption) // Style as per TR-IM-004 (e.g., smaller font)
                        .foregroundColor(.gray) // Subtle color
                        .multilineTextAlignment(.center) // Center if it's long
                }

                // Existing NavigationStackStore
                NavigationStackStore(
                    self.store.scope(state: \.path, action: { .path($0) })
                ) {
                    FastingView(
                        store: self.store.scope(
                            state: \.fasting,
                            action: { .fasting($0) }
                        )
                    )
                } destination: { state in
                    switch state {
                    case .history:
                        CaseLet(
                            /AppFeature.Path.State.history,
                            action: AppFeature.Path.Action.history,
                            then: HistoryView.init(store:)
                        )
                    }
                }
            }
            .onAppear {
                viewStore.send(.loadInspirationalMessage)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(),
            reducer: { AppFeature() }
        )
    )
}
