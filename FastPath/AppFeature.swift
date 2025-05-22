//
//  AppFeature.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ComposableArchitecture
import Foundation // Ensure Foundation is imported

struct UserDefaultsClient {
    var integerForKey: @Sendable (String) -> Int? // Make @Sendable for actor safety
    var setInteger: @Sendable (Int, String) async -> Void // Make async if it could involve async operations, though UserDefaults is sync
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        integerForKey: { key in
            // UserDefaults.integer(forKey:) returns 0 if key DNE or is not an Int.
            // To correctly return nil if the key genuinely doesn't exist,
            // we check object(forKey:) first.
            if UserDefaults.standard.object(forKey: key) == nil {
                return nil
            }
            return UserDefaults.standard.integer(forKey: key)
        },
        setInteger: { value, key in
            UserDefaults.standard.set(value, forKey: key)
        }
    )

    // Add a testValue if you plan to write tests for this
    static let testValue = Self(
        integerForKey: { _ in nil }, // Default test implementation
        setInteger: { _, _ in }
    )
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

@Reducer
struct AppFeature {
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    struct State: Equatable {
        var fasting = FastingFeature.State()
        var path = StackState<Path.State>()
        var currentInspirationalMessage: String? = nil
    }
    
    enum Action: Equatable {
        case fasting(FastingFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        case loadInspirationalMessage
        case inspirationalMessageResponse(String)
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
            
            case .loadInspirationalMessage:
                let lastDisplayedMessageIndex = userDefaultsClient.integerForKey("lastDisplayedMessageIndex") ?? -1
                
                guard !Quotes.allMessages.isEmpty else {
                    return .send(.inspirationalMessageResponse("No messages available."))
                }
                
                let nextIndex = (lastDisplayedMessageIndex + 1) % Quotes.allMessages.count
                let message = Quotes.allMessages[nextIndex]
                
                return .run { send in
                    await userDefaultsClient.setInteger(nextIndex, "lastDisplayedMessageIndex")
                    await send(.inspirationalMessageResponse(message))
                }

            case .inspirationalMessageResponse(let message):
                state.currentInspirationalMessage = message
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
