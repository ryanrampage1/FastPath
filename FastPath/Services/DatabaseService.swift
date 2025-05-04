//
//  DatabaseService.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation

/// Service for handling database operations for fasting records
class DatabaseService {
    private let userDefaults = UserDefaults.standard
    private let fastingRecordsKey = "fastingRecords"
    
    init() {}
    
    // Singleton instance
    static let shared = DatabaseService()
    
    /// Save a fasting record to the database
    func save(_ record: FastingRecord) async throws {
        var records = await getAllRecords()
        records.append(record)
        saveAllRecords(records)
    }
    
    /// Update an existing fasting record
    func update(_ record: FastingRecord) async throws {
        var records = await getAllRecords()
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            saveAllRecords(records)
        }
    }
    
    /// Get all fasting records, ordered by start time (most recent first)
    func getAllRecords() async -> [FastingRecord] {
        guard let data = userDefaults.data(forKey: fastingRecordsKey),
              let records = try? JSONDecoder().decode([FastingRecord].self, from: data) else {
            return []
        }
        return records.sorted(by: { $0.startTime > $1.startTime })
    }
    
    /// Get the most recent active fasting record (if any)
    func getActiveRecord() async -> FastingRecord? {
        let records = await getAllRecords()
        return records.first(where: { $0.endTime == nil })
    }
    
    /// Delete a fasting record by ID
    func deleteRecord(withId id: UUID) async {
        var records = await getAllRecords()
        records.removeAll(where: { $0.id == id })
        saveAllRecords(records)
    }
    
    /// Private helper to save all records
    private func saveAllRecords(_ records: [FastingRecord]) {
        if let data = try? JSONEncoder().encode(records) {
            userDefaults.set(data, forKey: fastingRecordsKey)
        }
    }
}
