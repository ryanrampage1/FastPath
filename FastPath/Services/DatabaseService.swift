//
//  DatabaseService.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import StructuredQueries

/// Service for handling database operations for fasting records
actor DatabaseService {
    private let database: Database
    
    init() async throws {
        // Initialize the database
        let url = try await URL.documentsDirectory.appending(path: "fastpath.db")
        self.database = try await Database(url: url)
        
        // Create the table if it doesn't exist
        try await database.create(table: FastingRecord.self, ifNotExists: true)
    }
    
    /// Save a fasting record to the database
    func save(_ record: FastingRecord) async throws {
        try await database.insert(record)
    }
    
    /// Update an existing fasting record
    func update(_ record: FastingRecord) async throws {
        try await database.update(record)
    }
    
    /// Get all fasting records, ordered by start time (most recent first)
    func getAllRecords() async throws -> [FastingRecord] {
        try await database.select(FastingRecord.self)
            .order(by: .desc(FastingRecord.schema["start_time"]))
            .all()
    }
    
    /// Get the most recent active fasting record (if any)
    func getActiveRecord() async throws -> FastingRecord? {
        try await database.select(FastingRecord.self)
            .where(FastingRecord.schema["end_time"].isNull)
            .first()
    }
}
