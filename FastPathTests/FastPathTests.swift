//
//  FastPathTests.swift
//  FastPathTests
//
//  Created by Ryan Casler on 5/4/25.
//

import Testing
import GRDB
@testable import FastPath // Import FastPath to access its types, including DatabaseService and models

@Suite("DatabaseService Tests")
struct FastPathTests {

    var dbQueue: DatabaseQueue!
    var sut: DatabaseService! // System Under Test

    @Test("Initial setup") func setup() async throws {
        dbQueue = try DatabaseQueue(configuration: .init(path: ":memory:"))
        sut = try DatabaseService(dbQueue: dbQueue) // This also calls createTablesIfNeeded and preloads goals
        
        // Verify predefined goals are loaded
        let predefinedGoals = FastingGoal.predefinedGoals
        let allGoalsInDb = try await sut.dbQueue.read { db in try FastingGoal.fetchAll(db) }
        #expect(allGoalsInDb.count == predefinedGoals.count, "Predefined goals should be loaded on initial setup")
    }

    // MARK: - FastingRecord Tests

    @Test("Save and Get Record")
    func testSaveAndGetRecord() async throws {
        try await setup() // Ensure fresh DB for each test logic block for now
        let record = FastingRecord(startTime: Date(), endTime: Date().addingTimeInterval(3600))
        try await sut.save(record)
        
        let fetchedRecord = try await sut.dbQueue.read { db in
            try FastingRecord.fetchOne(db, key: record.id)
        }
        #expect(fetchedRecord != nil, "Record should be fetched")
        #expect(fetchedRecord?.id == record.id, "Fetched record ID should match saved record ID")
        #expect(fetchedRecord?.startTime == record.startTime, "Fetched record startTime should match")
        // Comparing dates directly can be tricky due to precision. For GRDB, it should be fine.
         if let fetchedEndTime = fetchedRecord?.endTime, let recordEndTime = record.endTime {
            #expect(abs(fetchedEndTime.timeIntervalSince(recordEndTime)) < 0.001, "Fetched record endTime should match")
        } else if fetchedRecord?.endTime != nil || record.endTime != nil {
            Issue.record("EndTime mismatch - one is nil, the other is not")
        }
    }

    @Test("Update Record")
    func testUpdateRecord() async throws {
        try await setup()
        var record = FastingRecord(startTime: Date())
        try await sut.save(record)
        
        let updatedEndTime = Date().addingTimeInterval(7200)
        record.endTime = updatedEndTime
        try await sut.update(record)
        
        let fetchedRecord = try await sut.dbQueue.read { db in
            try FastingRecord.fetchOne(db, key: record.id)
        }
        #expect(fetchedRecord != nil, "Record should exist after update")
        #expect(fetchedRecord?.endTime != nil, "Updated record endTime should not be nil")
        if let fetchedEndTime = fetchedRecord?.endTime {
             #expect(abs(fetchedEndTime.timeIntervalSince(updatedEndTime)) < 0.001, "Fetched record endTime should match updated endTime")
        }
    }

    @Test("Get All Records - Ordering")
    func testGetAllRecords_Ordering() async throws {
        try await setup()
        let now = Date()
        let record1 = FastingRecord(startTime: now.addingTimeInterval(-3600)) // Older
        let record2 = FastingRecord(startTime: now) // Newer
        try await sut.save(record1)
        try await sut.save(record2)
        
        let allRecords = await sut.getAllRecords()
        #expect(allRecords.count == 2, "Should fetch 2 records")
        #expect(allRecords.first?.id == record2.id, "First record should be the newest (record2)")
        #expect(allRecords.last?.id == record1.id, "Last record should be the oldest (record1)")
    }
    
    @Test("Get All Records - Empty")
    func testGetAllRecords_Empty() async throws {
        try await setup()
        // Clear any predefined goals that might affect other tests if not careful with setup logic
        try await sut.dbQueue.write { db in _ = try FastingRecord.deleteAll(db) }

        let allRecords = await sut.getAllRecords()
        #expect(allRecords.isEmpty, "getAllRecords should return empty when no records exist")
    }

    @Test("Get Active Record - Exists")
    func testGetActiveRecord_Exists() async throws {
        try await setup()
        let activeRecord = FastingRecord(startTime: Date(), endTime: nil)
        let completedRecord = FastingRecord(startTime: Date().addingTimeInterval(-7200), endTime: Date().addingTimeInterval(-3600))
        try await sut.save(activeRecord)
        try await sut.save(completedRecord)
        
        let fetchedActiveRecord = await sut.getActiveRecord()
        #expect(fetchedActiveRecord != nil, "Active record should be found")
        #expect(fetchedActiveRecord?.id == activeRecord.id, "Fetched active record ID should match")
        #expect(fetchedActiveRecord?.isActive == true, "Fetched record should be active")
    }

    @Test("Get Active Record - None Exists")
    func testGetActiveRecord_NoneExists() async throws {
        try await setup()
        let completedRecord = FastingRecord(startTime: Date().addingTimeInterval(-7200), endTime: Date().addingTimeInterval(-3600))
        try await sut.save(completedRecord)
        
        let fetchedActiveRecord = await sut.getActiveRecord()
        #expect(fetchedActiveRecord == nil, "No active record should be found")
    }

    @Test("Delete Record")
    func testDeleteRecord() async throws {
        try await setup()
        let record = FastingRecord(startTime: Date())
        try await sut.save(record)
        
        try await sut.deleteRecord(withId: record.id)
        
        let fetchedRecord = try await sut.dbQueue.read { db in
            try FastingRecord.fetchOne(db, key: record.id)
        }
        #expect(fetchedRecord == nil, "Record should be deleted")
    }

    // MARK: - FastingGoal Tests

    @Test("Save and Get Goal")
    func testSaveAndGetGoal() async throws {
        try await setup()
        // Clear predefined goals to test saving a specific one in isolation for getGoal()
        try await sut.dbQueue.write { db in _ = try FastingGoal.deleteAll(db) }

        let goal = FastingGoal(targetDuration: 10 * 3600, name: "10-Hour Test Fast", description: "Test description")
        try await sut.saveGoal(goal)
        
        let fetchedGoal = await sut.getGoal() // Relies on getGoal fetching the first/only one
        #expect(fetchedGoal != nil, "Goal should be fetched")
        #expect(fetchedGoal?.name == goal.name, "Fetched goal name should match")
        #expect(fetchedGoal?.targetDuration == goal.targetDuration, "Fetched goal duration should match")
    }
    
    @Test("Save Goal - Upsert")
    func testSaveGoal_Upsert() async throws {
        try await setup()
        let initialGoal = FastingGoal(targetDuration: 12 * 3600, name: "Upsert Test", description: "Initial")
        try await sut.saveGoal(initialGoal)

        let updatedGoal = FastingGoal(targetDuration: 13 * 3600, name: "Upsert Test", description: "Updated")
        try await sut.saveGoal(updatedGoal)

        let fetchedGoal = await sut.getGoal(named: "Upsert Test")
        #expect(fetchedGoal != nil, "Goal should exist")
        #expect(fetchedGoal?.targetDuration == 13 * 3600, "Goal duration should be updated")
        #expect(fetchedGoal?.description == "Updated", "Goal description should be updated")

        let allGoals = try await sut.dbQueue.read { db in try FastingGoal.fetchAll(db) }
        let upsertTestGoals = allGoals.filter { $0.name == "Upsert Test" }
        #expect(upsertTestGoals.count == 1, "There should be only one goal named 'Upsert Test' after upsert")
    }

    @Test("Save Nil Goal - Deletes All Goals")
    func testSaveNilGoal_DeletesAllGoals() async throws {
        try await setup() // Setup loads predefined goals
        let initialGoalsCount = FastingGoal.predefinedGoals.count
        #expect(initialGoalsCount > 0, "Test assumes predefined goals exist")

        var goalsInDb = await sut.dbQueue.read { db in try FastingGoal.fetchAll(db) }
        #expect(goalsInDb.count == initialGoalsCount, "Predefined goals should be loaded initially")

        try await sut.saveGoal(nil) // Delete all goals
        
        goalsInDb = await sut.dbQueue.read { db in try FastingGoal.fetchAll(db) }
        #expect(goalsInDb.isEmpty, "All goals should be deleted after saving nil")
    }

    @Test("Get Goal Named - Exists")
    func testGetGoal_Named_Exists() async throws {
        try await setup() // Predefined goals are loaded
        let targetGoalName = FastingGoal.predefinedGoals[0].name
        
        let fetchedGoal = await sut.getGoal(named: targetGoalName)
        #expect(fetchedGoal != nil, "Specific predefined goal should be fetched by name")
        #expect(fetchedGoal?.name == targetGoalName, "Fetched goal name should match requested name")
    }

    @Test("Get Goal Named - Not Exists")
    func testGetGoal_Named_NotExists() async throws {
        try await setup()
        let fetchedGoal = await sut.getGoal(named: "NonExistentGoalName")
        #expect(fetchedGoal == nil, "Fetching a non-existent goal by name should return nil")
    }
    
    @Test("Test Predefined Goals are Loaded")
    func testPredefinedGoals_AreLoaded() async throws {
        try await setup() // Setup method already calls the initializer that loads goals
        let predefinedGoals = FastingGoal.predefinedGoals
        #expect(!predefinedGoals.isEmpty, "Test requires predefined goals to exist for validation.")

        for goal in predefinedGoals {
            let fetchedGoal = await sut.getGoal(named: goal.name)
            #expect(fetchedGoal != nil, "Predefined goal '\(goal.name)' should be loaded.")
            #expect(fetchedGoal?.targetDuration == goal.targetDuration, "Predefined goal '\(goal.name)' duration should match.")
        }
        
        let allGoalsInDb = try await sut.dbQueue.read { db in try FastingGoal.fetchAll(db) }
        #expect(allGoalsInDb.count == predefinedGoals.count, "The number of goals in DB should match the number of predefined goals.")
    }
}

// Helper to make Date comparison more robust if needed, though GRDB's precision is usually good.
// For this exercise, direct comparison or timeIntervalSince comparison with a small epsilon is used.
extension Date {
    func isClose(to otherDate: Date, precision: TimeInterval = 0.001) -> Bool {
        return abs(self.timeIntervalSince(otherDate)) < precision
    }
}
