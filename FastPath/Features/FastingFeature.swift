//
//  FastingFeature.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FastingFeature {
    // MARK: - State
    
    struct State: Equatable {
        var activeRecord: FastingRecord?
        var fastingHistory: [FastingRecord] = []
        var isLoading: Bool = false
        var currentElapsedTime: TimeInterval = 0
        
        var isFasting: Bool {
            activeRecord != nil
        }
    }
    
    // MARK: - Actions
    
    enum Action: Equatable {
        // User actions
        case startFastButtonTapped
        case stopFastButtonTapped
        case historyButtonTapped
        
        // Internal actions
        case timerTick
        case loadInitialState
        case fastingHistoryLoaded([FastingRecord])
        case activeRecordLoaded(FastingRecord?)
        case fastingRecordSaved(FastingRecord)
        case fastingStopped(FastingRecord)
        
        // Navigation
        case showHistory
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.databaseClient) var databaseClient
    
    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadInitialState:
                state.isLoading = true
                return .run { send in
                    // Load active record
                    let activeRecord = await databaseClient.getActiveRecord()
                    await send(.activeRecordLoaded(activeRecord))
                    
                    // Load history
                    let history = await databaseClient.getAllRecords()
                    await send(.fastingHistoryLoaded(history))
                }
                
            case let .activeRecordLoaded(record):
                state.activeRecord = record
                state.isLoading = false
                
                // If there's an active fast, start the timer
                if record != nil {
                    return .run { send in
                        for await _ in self.clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    }
                } else {
                    return .none
                }
                
            case let .fastingHistoryLoaded(history):
                state.fastingHistory = history
                return .none
                
            case .startFastButtonTapped:
                let newRecord = FastingRecord(startTime: Date())
                state.activeRecord = newRecord
                
                return .run { send in
                    try await databaseClient.save(newRecord)
                    await send(.fastingRecordSaved(newRecord))
                    
                    // Start timer
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTick)
                    }
                }
                
            case .stopFastButtonTapped:
                guard var record = state.activeRecord else { return .none }
                record.endTime = Date()
                state.activeRecord = nil
                
                return .run { send in
                    try await databaseClient.update(record)
                    await send(.fastingStopped(record))
                    
                    // Refresh history
                    let history = await databaseClient.getAllRecords()
                    await send(.fastingHistoryLoaded(history))
                }
                
            case let .fastingRecordSaved(record):
                // Update state if needed
                if state.activeRecord?.id == record.id {
                    state.activeRecord = record
                }
                return .none
                
            case let .fastingStopped(record):
                // Add to history if not already there
                if !state.fastingHistory.contains(where: { $0.id == record.id }) {
                    state.fastingHistory.insert(record, at: 0)
                }
                state.currentElapsedTime = 0
                return .none
                
            case .timerTick:
                guard let startTime = state.activeRecord?.startTime else { return .none }
                state.currentElapsedTime = Date().timeIntervalSince(startTime)
                return .none
                
            case .historyButtonTapped:
                return .send(.showHistory)
                
            case .showHistory:
                // This will be handled by the parent reducer for navigation
                return .none
            }
        }
    }
}

// MARK: - Dependencies

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

// MARK: - Database Client Interface

struct DatabaseClient {
    var save: @Sendable (FastingRecord) async throws -> Void
    var update: @Sendable (FastingRecord) async throws -> Void
    var getAllRecords: @Sendable () async -> [FastingRecord]
    var getActiveRecord: @Sendable () async -> FastingRecord?
    
    static let live = Self(
        save: { record in
            try await DatabaseService.shared.save(record)
        },
        update: { record in
            try await DatabaseService.shared.update(record)
        },
        getAllRecords: {
            await DatabaseService.shared.getAllRecords()
        },
        getActiveRecord: {
            await DatabaseService.shared.getActiveRecord()
        }
    )
}

extension DatabaseClient: DependencyKey {
    static var liveValue = DatabaseClient.live
    
    static var testValue = Self(
        save: { _ in },
        update: { _ in },
        getAllRecords: { [] },
        getActiveRecord: { nil }
    )
}
