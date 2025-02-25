//
//  Untitled.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent

class FriendsFeedViewModelTests: XCTestCase {
    
    // No setUp/tearDown since we'll instantiate in each test also actors..
    
    func testInitialFetchActivities() async {
        // Arrange
        let mockRepository = MockFriendsActivityRepository()
        let mockUserReactionStore = MockUserReactionStore()
        let sampleActivity = FriendActivity(
            userId: "1",
            imageUrl: "https://example.com/test.png",
            name: "Test",
            timestamp: Date(),
            activityTitle: "Test Activity",
            activityMainEmoji: "🔥",
            reactions: [Reaction(emoji: "👍", count: 1)]
        )
        mockRepository.mockActivities = [sampleActivity]
        
        // Act
        let viewModel = await FriendsFeedViewModel(repository: mockRepository, userReactionStore: mockUserReactionStore)
        await viewModel.fetchActivities()
        
        // Assert
        if case .loaded(let activities) = await viewModel.state {
            XCTAssertEqual(activities.count, 1)
            XCTAssertEqual(activities[0], sampleActivity)
        } else {
            XCTFail("State should be .loaded after successful fetch")
        }
    }
    
    func testAddReaction() async {
        // Arrange
        let mockRepository = MockFriendsActivityRepository()
        let mockUserReactionStore = MockUserReactionStore()
        let sampleActivity = FriendActivity(
            userId: "1",
            imageUrl: "https://example.com/test.png",
            name: "Test",
            timestamp: Date(),
            activityTitle: "Test Activity",
            activityMainEmoji: "🔥",
            reactions: [Reaction(emoji: "👍", count: 1)]
        )
        mockRepository.mockActivities = [sampleActivity]
        
        let viewModel = await FriendsFeedViewModel(repository: mockRepository, userReactionStore: mockUserReactionStore)
        await viewModel.fetchActivities() // Set initial state
        let emoji = "🔥"
        
        await viewModel.addReaction(emoji, to: sampleActivity)
        
        // Assert
        if case .loaded(let activities) = await viewModel.state,
           let updatedActivity = activities.first {
            XCTAssertEqual(updatedActivity.reactions.count, 2)
            XCTAssertTrue(updatedActivity.reactions.contains { $0.emoji == "👍" && $0.count == 1 })
            XCTAssertTrue(updatedActivity.reactions.contains { $0.emoji == "🔥" && $0.count == 1 })
            XCTAssertTrue(mockUserReactionStore.reactions.contains(emoji))
        } else {
            XCTFail("State should be .loaded after adding reaction")
        }
    }
    
    func testRemoveReaction() async {
        // Arrange
        let mockRepository = MockFriendsActivityRepository()
        let mockUserReactionStore = MockUserReactionStore()
        let sampleActivity = FriendActivity(
            userId: "1",
            imageUrl: "https://example.com/test.png",
            name: "Test",
            timestamp: Date(),
            activityTitle: "Test Activity",
            activityMainEmoji: "🔥",
            reactions: [Reaction(emoji: "👍", count: 2)]
        )
        mockRepository.mockActivities = [sampleActivity]
        
        let viewModel = await FriendsFeedViewModel(repository: mockRepository, userReactionStore: mockUserReactionStore)
        await viewModel.fetchActivities() // Set initial state
        mockUserReactionStore.reactions = ["👍"]
        let emoji = "👍"
        
        // Act
        await viewModel.removeReaction(emoji, from: sampleActivity)
        
        // Assert
        if case .loaded(let activities) = await viewModel.state,
           let updatedActivity = activities.first {
            XCTAssertEqual(updatedActivity.reactions.count, 1)
            XCTAssertTrue(updatedActivity.reactions.contains { $0.emoji == "👍" && $0.count == 1 })
            XCTAssertFalse(mockUserReactionStore.reactions.contains(emoji))
        } else {
            XCTFail("State should be .loaded after removing reaction")
        }
    }
}

// Mock implementations
class MockFriendsActivityRepository: FriendsActivityRepositoryProtocol {
    var mockActivities: [FriendActivity]?
    
    func fetchFriendsActivity() async throws -> [FriendActivity] {
        guard let activities = mockActivities else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock data"])
        }
        return activities
    }
}

class MockUserReactionStore: UserReactionStore {
    var reactions: Set<String> = []
    
    override func addReaction(_ emoji: String, userId: String, activityTitle: String) {
        reactions.insert(emoji)
    }
    
    override func removeReaction(_ emoji: String, userId: String, activityTitle: String) {
        reactions.remove(emoji)
    }
    
    override func getUserReactions(userId: String, activityTitle: String) -> Set<String> {
        return reactions
    }
}
