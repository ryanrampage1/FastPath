//
//  FastingRecord.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import StructuredQueries

/// Represents a single fasting record with start and end times
struct FastingRecord: Identifiable, Equatable, Codable {
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
    
    init(id: UUID = UUID(), startTime: Date = Date(), endTime: Date? = nil) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}

// Extension for Swift Structured Queries compatibility
extension FastingRecord: Queryable {
    static let schema = Schema(
        "fasting_records",
        id: Column("id", .uuid),
        Column("start_time", .date),
        Column("end_time", .date, nullable: true)
    )
}
