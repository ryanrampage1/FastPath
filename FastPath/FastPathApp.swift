//
//  FastPathApp.swift
//  FastPath
//
//  Created by Ryan Casler on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

@main
struct FastPathApp: App {
    let store = Store(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
    )
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
