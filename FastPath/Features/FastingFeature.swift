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
        var fastingGoal: FastingGoal?
        var showingGoalPicker: Bool = false
        
        var isFasting: Bool {
            activeRecord != nil
        }
        
        var remainingTimeToGoal: TimeInterval? {
            guard let goal = fastingGoal, isFasting else { return nil }
            let goalDuration = goal.targetDuration
            let remainingTime = goalDuration - currentElapsedTime
            return remainingTime > 0 ? remainingTime : 0
        }
        
        var hasReachedGoal: Bool {
            guard let remainingTime = remainingTimeToGoal else { return false }
            return remainingTime == 0
        }
    }
    
    // MARK: - Actions
    
    enum Action: Equatable {
        // User actions
        case startFastButtonTapped
        case stopFastButtonTapped
        case historyButtonTapped
        case deleteRecordButtonTapped(UUID)
        case setGoalButtonTapped
        case goalPickerDismissed
        case selectPredefinedGoal(FastingGoal)
        case setCustomGoal(TimeInterval)
        case clearGoal
        
        // Internal actions
        case timerTick
        case loadInitialState
        case fastingHistoryLoaded([FastingRecord])
        case activeRecordLoaded(FastingRecord?)
        case fastingRecordSaved(FastingRecord)
        case fastingStopped(FastingRecord)
        case recordDeleted(UUID)
        case fastingGoalLoaded(FastingGoal?)
        case fastingGoalSaved(FastingGoal?)
        
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
                    
                    // Load fasting goal
                    let goal = await databaseClient.getGoal()
                    await send(.fastingGoalLoaded(goal))
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
                
            case .deleteRecordButtonTapped(let recordId):
                return .run { send in
                    await databaseClient.delete(recordId)
                    await send(.recordDeleted(recordId))
                    
                    // Refresh history after deletion
                    let updatedHistory = await databaseClient.getAllRecords()
                    await send(.fastingHistoryLoaded(updatedHistory))
                }
                
            case .recordDeleted(let recordId):
                // Remove the record from the local state
                state.fastingHistory.removeAll(where: { $0.id == recordId })
                return .none
                
            case .fastingGoalLoaded(let goal):
                state.fastingGoal = goal
                return .none
                
            case .setGoalButtonTapped:
                state.showingGoalPicker = true
                return .none
                
            case .goalPickerDismissed:
                state.showingGoalPicker = false
                return .none
                
            case .selectPredefinedGoal(let goal):
                state.fastingGoal = goal
                state.showingGoalPicker = false
                return .run { send in
                    await databaseClient.saveGoal(goal)
                    await send(.fastingGoalSaved(goal))
                }
                
            case .setCustomGoal(let duration):
                let customGoal = FastingGoal(targetDuration: duration, name: "Custom Goal")
                state.fastingGoal = customGoal
                state.showingGoalPicker = false
                return .run { send in
                    await databaseClient.saveGoal(customGoal)
                    await send(.fastingGoalSaved(customGoal))
                }
                
            case .clearGoal:
                state.fastingGoal = nil
                return .run { send in
                    await databaseClient.saveGoal(nil)
                    await send(.fastingGoalSaved(nil))
                }
                
            case .fastingGoalSaved:
                // Nothing to do here, state is already updated
                return .none
                
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
    var delete: @Sendable (UUID) async -> Void
    var getAllRecords: @Sendable () async -> [FastingRecord]
    var getActiveRecord: @Sendable () async -> FastingRecord?
    var saveGoal: @Sendable (FastingGoal?) async -> Void
    var getGoal: @Sendable () async -> FastingGoal?
    
    static let live = Self(
        save: { record in
            try await DatabaseService.shared.save(record)
        },
        update: { record in
            try await DatabaseService.shared.update(record)
        },
        delete: { id in
            await DatabaseService.shared.deleteRecord(withId: id)
        },
        getAllRecords: {
            await DatabaseService.shared.getAllRecords()
        },
        getActiveRecord: {
            await DatabaseService.shared.getActiveRecord()
        },
        saveGoal: { goal in
            await DatabaseService.shared.saveGoal(goal)
        },
        getGoal: {
            await DatabaseService.shared.getGoal()
        }
    )
}

extension DatabaseClient: DependencyKey {
    static var liveValue = DatabaseClient.live
    
    static var testValue = Self(
        save: { _ in },
        update: { _ in },
        delete: { _ in },
        getAllRecords: { [] },
        getActiveRecord: { nil },
        saveGoal: { _ in },
        getGoal: { nil }
    )
}
