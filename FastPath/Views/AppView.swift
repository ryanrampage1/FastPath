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
        NavigationStackStore(
            store.scope(state: \.path, action: { .path($0) })
        ) {
            FastingView(
                store: store.scope(
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
}

#Preview {
    AppView(
        store: Store(
            initialState: AppFeature.State(),
            reducer: { AppFeature() }
        )
    )
}
