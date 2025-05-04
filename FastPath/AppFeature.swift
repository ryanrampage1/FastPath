//
//  AppFeature.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var fasting = FastingFeature.State()
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case fasting(FastingFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Reducer
    struct Path {
        enum State: Equatable {
            case history(FastingFeature.State)
        }
        
        enum Action: Equatable {
            case history(FastingFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: /State.history, action: /Action.history) {
                FastingFeature()
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.fasting, action: /Action.fasting) {
            FastingFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .fasting(.showHistory):
                state.path.append(.history(state.fasting))
                return .none
                
            case .fasting:
                return .none
                
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
