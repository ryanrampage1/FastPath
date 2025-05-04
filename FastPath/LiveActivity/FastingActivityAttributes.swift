//
//  FastingActivityAttributes.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import ActivityKit

/// Defines the attributes for the fasting Live Activity
struct FastingActivityAttributes: ActivityAttributes {
    public typealias FastingStatus = ContentState
    
    /// The unique identifier for the fasting session
    let fastId: UUID
    
    /// The start time of the fast
    let startTime: Date
    
    /// The target duration in seconds
    let goalDuration: TimeInterval
    
    /// The name of the fasting goal (e.g., "16:8 Intermittent Fasting")
    let goalName: String?
    
    /// Content state that can be updated while the Live Activity is running
    public struct ContentState: Codable, Hashable {
        /// The current elapsed time in seconds
        var elapsedTime: TimeInterval
        
        /// The remaining time until the goal is reached in seconds
        var remainingTime: TimeInterval
        
        /// Whether the goal has been reached
        var goalReached: Bool
    }
}
