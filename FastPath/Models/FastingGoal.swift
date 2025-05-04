//
//  FastingGoal.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation

/// Represents a fasting goal with a target duration
struct FastingGoal: Equatable, Codable {
    /// Duration in seconds
    var targetDuration: TimeInterval
    
    /// Optional name for the goal (e.g., "16:8 Intermittent Fasting")
    var name: String?
    
    /// Optional description for the goal
    var description: String?
    
    init(targetDuration: TimeInterval, name: String? = nil, description: String? = nil) {
        self.targetDuration = targetDuration
        self.name = name
        self.description = description
    }
    
    /// Predefined fasting goals based on common patterns
    static let predefinedGoals: [FastingGoal] = [
        FastingGoal(
            targetDuration: 14 * 3600, // 14 hours in seconds
            name: "14-Hour Fast",
            description: "A gentle start to time-restricted eating."
        ),
        FastingGoal(
            targetDuration: 16 * 3600, // 16 hours in seconds
            name: "16-Hour Fast",
            description: "A popular choice, may aid weight management and blood sugar control."
        ),
        FastingGoal(
            targetDuration: 18 * 3600, // 18 hours in seconds
            name: "18-Hour Fast",
            description: "A longer fast, potentially enhancing fat burning and focus."
        ),
        FastingGoal(
            targetDuration: 20 * 3600, // 20 hours in seconds
            name: "20-Hour Fast",
            description: "An extended daily fast."
        )
    ]
}
