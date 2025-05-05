//
//  LiveActivityService.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import ActivityKit

/// Service for managing Live Activities for the fasting timer
class LiveActivityService {
    // Singleton instance
    static let shared = LiveActivityService()
    
    private init() {}
    
    /// The current active fasting activity
    private var currentActivity: Activity<FastingActivityAttributes>?
    
    /// Start a new Live Activity for a fasting session
    /// - Parameters:
    ///   - fastId: The unique identifier for the fast
    ///   - startTime: The start time of the fast
    ///   - goalDuration: The target duration in seconds
    ///   - goalName: Optional name for the goal
    /// - Returns: Whether the activity was successfully started
    @discardableResult
    func startFastingActivity(fastId: UUID, startTime: Date, goalDuration: TimeInterval, goalName: String? = nil) -> Bool {
        // Check if Live Activities are supported on this device
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not supported on this device")
            return false
        }
        
        // Stop any existing activity
        stopCurrentActivity()
        
        // Create the initial content state
        let initialContentState = FastingActivityAttributes.FastingStatus(
            elapsedTime: 0,
            remainingTime: goalDuration,
            goalReached: false
        )
        
        // Create the activity attributes
        let activityAttributes = FastingActivityAttributes(
            fastId: fastId,
            startTime: startTime,
            goalDuration: goalDuration,
            goalName: goalName
        )
        
        do {
            // Start the Live Activity
            let activity = try Activity.request(
                attributes: activityAttributes,
                contentState: initialContentState,
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity with ID: \(activity.id)")
            return true
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Update the current Live Activity with new elapsed and remaining times
    /// - Parameters:
    ///   - elapsedTime: The current elapsed time in seconds
    ///   - remainingTime: The remaining time until the goal is reached in seconds
    ///   - goalReached: Whether the goal has been reached
    func updateActivity(elapsedTime: TimeInterval, remainingTime: TimeInterval, goalReached: Bool) {
        guard let activity = currentActivity else { return }
        
        // Create the updated content state
        let updatedContentState = FastingActivityAttributes.FastingStatus(
            elapsedTime: elapsedTime,
            remainingTime: max(0, remainingTime), // Ensure remaining time is not negative
            goalReached: goalReached
        )
        
        // Update the activity
        Task {
            await activity.update(using: updatedContentState)
        }
    }
    
    /// Stop the current Live Activity
    func stopCurrentActivity() {
        guard let activity = currentActivity else { return }
        
        // End the activity
        Task {
            await activity.end(
                using: activity.contentState,
                dismissalPolicy: .immediate
            )
            currentActivity = nil
        }
    }
    
    /// Check if there's an active Live Activity
    var hasActiveActivity: Bool {
        return currentActivity != nil
    }
}
