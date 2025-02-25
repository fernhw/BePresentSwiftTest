//
//  FriendsActivityRepositoryTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent
import Alamofire


class FriendsActivityRepositoryTests: XCTestCase {
    
    var repository: FriendsActivityRepository!
    var mockAPIClient: MockAPIClient!
    
    let sampleDate1 = ISO8601DateFormatter().date(from: "2023-02-28T15:00:00Z")!
    let sampleDate2 = ISO8601DateFormatter().date(from: "2023-02-28T16:00:00Z")!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        repository = nil
        mockAPIClient = nil
        super.tearDown()
    }
    
    // Test successful fetch with sorted activities
    func testFetchFriendsActivitySuccess() async throws {
        let unsortedActivities = [
            FriendActivity(
                userId: "user2",
                imageUrl: "https://example.com/user2.png",
                name: "Jane",
                timestamp: sampleDate2,
                activityTitle: "Later activity",
                activityMainEmoji: "🚀",
                reactions: [Reaction(emoji: "👍", count: 1)]
            ),
            FriendActivity(
                userId: "user1",
                imageUrl: "https://example.com/user1.png",
                name: "John",
                timestamp: sampleDate1,
                activityTitle: "Earlier activity",
                activityMainEmoji: "🎉",
                reactions: [Reaction(emoji: "🔥", count: 2)]
            )
        ]
        mockAPIClient = MockAPIClient(shouldSucceed: true, mockActivities: unsortedActivities)
        repository = FriendsActivityRepository(apiClient: mockAPIClient)
        
        // Act
        let activities = try await repository.fetchFriendsActivity()
        
        // Assert
        XCTAssertEqual(activities.count, 2)
        XCTAssertEqual(activities[0].userId, "user2") // Later activity first
        XCTAssertEqual(activities[0].timestamp, sampleDate2)
        XCTAssertEqual(activities[1].userId, "user1") // Earlier activity second
        XCTAssertEqual(activities[1].timestamp, sampleDate1)
    }
    
    // Test fetch with API failure
    func testFetchFriendsActivityFailure() async {
        let mockError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
        mockAPIClient = MockAPIClient(shouldSucceed: false, mockError: mockError)
        repository = FriendsActivityRepository(apiClient: mockAPIClient)
        
        do {
            _ = try await repository.fetchFriendsActivity()
            XCTFail("Expected fetch to throw an error")
        } catch {
            XCTAssertEqual((error as? AFError)?.responseCode, 404)
        }
    }
    
    // Test sorting logic with multiple activities
    func testFetchFriendsActivitySorting() async throws {
        // Arrange
        let unsortedActivities = [
            FriendActivity(
                userId: "user1",
                imageUrl: "https://example.com/user1.png",
                name: "John",
                timestamp: sampleDate1, // Earlier
                activityTitle: "First activity",
                activityMainEmoji: "🎉",
                reactions: []
            ),
            FriendActivity(
                userId: "user3",
                imageUrl: "https://example.com/user3.png",
                name: "Alice",
                timestamp: ISO8601DateFormatter().date(from: "2023-02-28T17:00:00Z")!, // Latest
                activityTitle: "Third activity",
                activityMainEmoji: "🌟",
                reactions: []
            ),
            FriendActivity(
                userId: "user2",
                imageUrl: "https://example.com/user2.png",
                name: "Jane",
                timestamp: sampleDate2, // Middle
                activityTitle: "Second activity",
                activityMainEmoji: "🚀",
                reactions: []
            )
        ]
        mockAPIClient = MockAPIClient(shouldSucceed: true, mockActivities: unsortedActivities)
        repository = FriendsActivityRepository(apiClient: mockAPIClient)
        
        // Act
        let activities = try await repository.fetchFriendsActivity()
        
        // Assert
        XCTAssertEqual(activities.count, 3)
        XCTAssertEqual(activities[0].timestamp, ISO8601DateFormatter().date(from: "2023-02-28T17:00:00Z")!) // Latest first
        XCTAssertEqual(activities[1].timestamp, sampleDate2) // Middle second
        XCTAssertEqual(activities[2].timestamp, sampleDate1) // Earliest last
    }
}
