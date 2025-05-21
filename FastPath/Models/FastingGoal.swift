//
//  FastingGoal.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import GRDB
import StructuredQueries

/// Represents a fasting goal with a target duration
@Table("fastingGoal")
class FastingGoal: Equatable, Codable, TableRecord, FetchableRecord, PersistableRecord {
    /// Duration in seconds
    var targetDuration: TimeInterval
    
    /// Name for the goal (e.g., "16:8 Intermittent Fasting"), serves as primary key.
    var name: String
    
    /// Optional description for the goal
    var description: String?
    
    init(targetDuration: TimeInterval, name: String, description: String? = nil) {
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

    // Required for TableRecord conformance
    // GRDB can use this to initialize instances from database rows.
    // We've defined 'name' as the primary key in the table schema.
    required init(row: Row) throws {
        name = row["name"]
        targetDuration = row["targetDuration"]
        description = row["description"]
    }

    // Required for PersistableRecord conformance
    // This tells GRDB how to persist the record to the database.
    func encode(to container: inout PersistenceContainer) throws {
        // 'name' is part of the primary key and should be included.
        container["name"] = name
        container["targetDuration"] = targetDuration
        container["description"] = description
    }

    // Equatable conformance
    static func == (lhs: FastingGoal, rhs: FastingGoal) -> Bool {
        return lhs.name == rhs.name &&
               lhs.targetDuration == rhs.targetDuration &&
               lhs.description == rhs.description
    }

    // If 'name' is the primary key, it should be used for Hashable conformance as well.
    // Codable conformance might require custom implementation if not all stored properties are Codable
    // or if there's specific encoding/decoding logic needed (GRDB handles its own persistence).
    // For simple Codable conformance for other uses (like JSON serialization), ensure all properties are Codable.
    // TimeInterval (Double), String, and String? are all Codable.
}
