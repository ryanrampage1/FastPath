//
//  FastPathApp.swift
//  FastPath
//
//  Created by Ryan Casler on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import WidgetKit

@main
struct FastPathApp: App {
    let store = Store(
        initialState: AppFeature.State(),
        reducer: { AppFeature() }
    )
    
    init() {
        // Register for Live Activities if available
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            // Ensure WidgetKit is aware of our Live Activity
            WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
