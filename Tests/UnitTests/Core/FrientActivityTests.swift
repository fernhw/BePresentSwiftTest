import XCTest
@testable import BePresent

class FriendActivityTests: XCTestCase {
    
    let sampleDate = ISO8601DateFormatter().date(from: "2023-02-28T15:00:00Z")!
    let sampleReactions = [
        Reaction(emoji: "👍", count: 5),
        Reaction(emoji: "🔥", count: 3)
    ]
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInitialization() {
        let activity = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        XCTAssertEqual(activity.userId, "user123")
        XCTAssertEqual(activity.imageUrl, "https://example.com/image.png")
        XCTAssertEqual(activity.name, "John Doe")
        XCTAssertEqual(activity.timestamp, sampleDate)
        XCTAssertEqual(activity.activityTitle, "Completed a task")
        XCTAssertEqual(activity.activityMainEmoji, "🎉")
        XCTAssertEqual(activity.reactions, sampleReactions)
    }
    
    func testImageURL() {
        let activity = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        XCTAssertEqual(activity.imageURL, URL(string: "https://example.com/image.png"))
        
        let invalidActivity = FriendActivity(
            userId: "user456",
            imageUrl: "",
            name: "Jane Doe",
            timestamp: sampleDate,
            activityTitle: "Another task",
            activityMainEmoji: "🚀",
            reactions: []
        )
        XCTAssertNil(invalidActivity.imageURL)
    }
    
    func testId() {
        let activity = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        let expectedId = "user123" + sampleDate.ISO8601Format()
        XCTAssertEqual(activity.id, expectedId)
    }
    
    func testEquatable() {
        let activity1 = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        let activity2 = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        let activity3 = FriendActivity(
            userId: "user456",
            imageUrl: "https://example.com/different.png",
            name: "Jane Doe",
            timestamp: sampleDate,
            activityTitle: "Another task",
            activityMainEmoji: "🚀",
            reactions: []
        )
        
        XCTAssertEqual(activity1, activity2)
        XCTAssertNotEqual(activity1, activity3)
    }
    
    func testEncoding() throws {
        let activity = FriendActivity(
            userId: "user123",
            imageUrl: "https://example.com/image.png",
            name: "John Doe",
            timestamp: sampleDate,
            activityTitle: "Completed a task",
            activityMainEmoji: "🎉",
            reactions: sampleReactions
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(activity)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedActivity = try decoder.decode(FriendActivity.self, from: jsonData)
        
        // Compare properties individually to avoid order issues with reactions
        XCTAssertEqual(decodedActivity.userId, activity.userId)
        XCTAssertEqual(decodedActivity.imageUrl, activity.imageUrl)
        XCTAssertEqual(decodedActivity.name, activity.name)
        XCTAssertEqual(decodedActivity.timestamp, activity.timestamp)
        XCTAssertEqual(decodedActivity.activityTitle, activity.activityTitle)
        XCTAssertEqual(decodedActivity.activityMainEmoji, activity.activityMainEmoji)
        XCTAssertEqual(decodedActivity.reactions.count, activity.reactions.count)
        XCTAssertTrue(decodedActivity.reactions.allSatisfy { decoded in
            activity.reactions.contains { $0 == decoded }
        })
    }
    
    func testDecoding() throws {
        let jsonString = """
        {
            "userId": "user123",
            "imageUrl": "https://example.com/image.png",
            "name": "John Doe",
            "timestamp": "2023-02-28T15:00:00Z",
            "activityTitle": "Completed a task",
            "activityMainEmoji": "🎉",
            "reactions": {
                "👍": 5,
                "🔥": 3
            }
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let activity = try decoder.decode(FriendActivity.self, from: jsonData)
        
        XCTAssertEqual(activity.userId, "user123")
        XCTAssertEqual(activity.imageUrl, "https://example.com/image.png")
        XCTAssertEqual(activity.name, "John Doe")
        XCTAssertEqual(activity.timestamp, sampleDate)
        XCTAssertEqual(activity.activityTitle, "Completed a task")
        XCTAssertEqual(activity.activityMainEmoji, "🎉")
        XCTAssertEqual(activity.reactions.count, 2)
        XCTAssertTrue(activity.reactions.contains { $0.emoji == "👍" && $0.count == 5 })
        XCTAssertTrue(activity.reactions.contains { $0.emoji == "🔥" && $0.count == 3 })
    }
    
    func testDecodingWithMissingReactions() throws {
        let jsonString = """
        {
            "userId": "user123",
            "imageUrl": "https://example.com/image.png",
            "name": "John Doe",
            "timestamp": "2023-02-28T15:00:00Z",
            "activityTitle": "Completed a task",
            "activityMainEmoji": "🎉"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let activity = try decoder.decode(FriendActivity.self, from: jsonData)
        
        XCTAssertEqual(activity.reactions, [])
    }
}
