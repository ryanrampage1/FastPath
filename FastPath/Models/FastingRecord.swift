//
//  FastingRecord.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import GRDB
import StructuredQueries

/// Represents a single fasting record with start and end times
@Table("fastingRecord")
class FastingRecord: Identifiable, Equatable, Codable, TableRecord, FetchableRecord, PersistableRecord {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    
    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
    
    var isActive: Bool {
        return endTime == nil
    }
    
    // Default initializer
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }

    // Required for TableRecord conformance if no other initializers are suitable
    // GRDB can often synthesize this if properties are straightforward
    required init(row: Row) throws {
        id = row["id"]
        startTime = row["startTime"]
        endTime = row["endTime"]
    }

    // Required for PersistableRecord conformance
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["startTime"] = startTime
        container["endTime"] = endTime
    }

    // Equatable conformance
    static func == (lhs: FastingRecord, rhs: FastingRecord) -> Bool {
        return lhs.id == rhs.id &&
               lhs.startTime == rhs.startTime &&
               lhs.endTime == rhs.endTime
    }
}


