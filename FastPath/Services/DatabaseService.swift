//
//  DatabaseService.swift
//  FastPath
//
//  Created on 5/4/25.
//

import Foundation
import GRDB
import StructuredQueries // Though not directly used in this file, good to have if extending queries

class DatabaseService {
    // MARK: - Properties
    
    /// A DatabaseQueue to connect to the database.
    ///
    /// Application Support Directory:
    /// We use the Application Support directory to store the database file.
    /// This directory is backed up by iCloud (if enabled) and is not deleted when the app is updated.
    private var dbQueue: DatabaseQueue
    
    // Singleton instance
    static let shared = DatabaseService()
    // Internal shared instance for testing
    static var sharedForTesting: DatabaseService!

    // MARK: - Initialization
    
    /// Initializes the DatabaseService for production use.
    /// Sets up the database connection to a file in Application Support and creates tables if they don't exist.
    private init() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dbURL = appSupportURL.appendingPathComponent("fastpath.sqlite")
            
            self.dbQueue = try DatabaseQueue(path: dbURL.path)
            
            try createTablesIfNeeded()
            
            // Preload default goals if the goals table is empty
            Task {
                if await getGoal() == nil {
                    for goal in FastingGoal.predefinedGoals {
                        try await saveGoal(goal)
                    }
                }
            }
            
        } catch {
            // TODO: Handle this error more gracefully in a production app
            fatalError("Failed to initialize database: \(error)")
        }
    }

    /// Initializes the DatabaseService with a specific DatabaseQueue (for testing).
    /// Also creates tables if they don't exist.
    internal init(dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        try createTablesIfNeeded()
        // Preload default goals for testing consistency if needed, or handle in test setup
        Task {
            if await getGoal() == nil {
                for goal in FastingGoal.predefinedGoals {
                    try await saveGoal(goal)
                }
            }
        }
    }
    
    /// Creates the necessary database tables if they don't already exist.
    private func createTablesIfNeeded() throws {
        try dbQueue.write { db in
            // FastingRecord table
            try db.create(table: FastingRecord.databaseTableName, ifNotExists: true) { t in
                t.primaryKey("id", .text).notNull() // UUID is stored as TEXT
                t.column("startTime", .datetime).notNull()
                t.column("endTime", .datetime)
            }
            
            // FastingGoal table
            try db.create(table: FastingGoal.databaseTableName, ifNotExists: true) { t in
                t.primaryKey("name", .text).notNull()
                t.column("targetDuration", .double).notNull() // TimeInterval is stored as DOUBLE
                t.column("description", .text)
            }
        }
    }
    
    // MARK: - Fasting Records
    
    /// Save a fasting record to the database.
    func save(_ record: FastingRecord) async throws {
        try await dbQueue.write { db in
            try record.insert(db)
        }
    }
    
    /// Update an existing fasting record.
    func update(_ record: FastingRecord) async throws {
        try await dbQueue.write { db in
            try record.update(db)
        }
    }
    
    /// Get all fasting records, ordered by start time (most recent first).
    func getAllRecords() async -> [FastingRecord] {
        do {
            return try await dbQueue.read { db in
                try FastingRecord.all().orderBy(Column("startTime").desc).fetchAll(db)
            }
        } catch {
            // TODO: Log error or handle more gracefully
            print("Error fetching all records: \(error)")
            return []
        }
    }
    
    /// Get the most recent active fasting record (if any).
    func getActiveRecord() async -> FastingRecord? {
        do {
            return try await dbQueue.read { db in
                try FastingRecord.filter(Column("endTime") == nil).fetchOne(db)
            }
        } catch {
            // TODO: Log error or handle more gracefully
            print("Error fetching active record: \(error)")
            return nil
        }
    }
    
    /// Delete a fasting record by ID.
    func deleteRecord(withId id: UUID) async throws {
        try await dbQueue.write { db in
            _ = try FastingRecord.deleteOne(db, key: id)
        }
    }
    
    // MARK: - Fasting Goals
    
    /// Save or update a fasting goal. If the goal with the same name exists, it's updated. Otherwise, it's inserted.
    /// If goal is nil, it deletes all existing goals.
    func saveGoal(_ goal: FastingGoal?) async throws {
        if let goalToSave = goal {
            try await dbQueue.write { db in
                try goalToSave.save(db) // save() handles insert or update
            }
        } else {
            // If goal is nil, remove all saved goals
            try await dbQueue.write { db in
                _ = try FastingGoal.deleteAll(db)
            }
        }
    }
    
    /// Get the saved fasting goal.
    /// For simplicity, this returns the first goal found.
    /// If specific goal identification is needed (e.g., by name, or a concept of "active" goal),
    /// this logic should be updated.
    func getGoal() async -> FastingGoal? {
        do {
            return try await dbQueue.read { db in
                try FastingGoal.fetchAll(db).first
            }
        } catch {
            // TODO: Log error or handle more gracefully
            print("Error fetching goal: \(error)")
            return nil
        }
    }

    /// Fetches a specific goal by its name.
    func getGoal(named name: String) async -> FastingGoal? {
        do {
            return try await dbQueue.read { db in
                try FastingGoal.filter(Column("name") == name).fetchOne(db)
            }
        } catch {
            print("Error fetching goal named \(name): \(error)")
            return nil
        }
    }
}
