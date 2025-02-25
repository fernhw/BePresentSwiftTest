//
//  ActivityCellViewTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent
import SwiftUI

class ActivityCellViewTests: XCTestCase {
    
    let sampleActivity = FriendActivity(
        userId: "1",
        imageUrl: "https://example.com/test.png",
        name: "Test User",
        timestamp: Date(),
        activityTitle: "Test Activity",
        activityMainEmoji: "🔥",
        reactions: [Reaction(emoji: "👍", count: 1)]
    )
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Helper to create an ActivityCellView instance
    private func createView(reactions: [Reaction]) -> ActivityCellView {
        let activity = FriendActivity(
            userId: sampleActivity.userId,
            imageUrl: sampleActivity.imageUrl,
            name: sampleActivity.name,
            timestamp: sampleActivity.timestamp,
            activityTitle: sampleActivity.activityTitle,
            activityMainEmoji: sampleActivity.activityMainEmoji,
            reactions: reactions
        )
        return ActivityCellView(
            activity: activity,
            dephaseAnimations: 0,
            onReactionTap: { _ in },
            onSelectorTap: { },
            pickerReaction: .constant(nil)
        )
    }
    
    func testCalculateReactionRows() {
        // Test with 0 reactions (just the + button)
        let view0 = createView(reactions: [])
        let rows0 = view0.calculateReactionRows()
        XCTAssertEqual(rows0, 1, "0 reactions + 1 for plus button should be 1 row")
        
        // Test with 4 reactions (5 items total)
        let view4 = createView(reactions: [
            Reaction(emoji: "👍", count: 1),
            Reaction(emoji: "🔥", count: 2),
            Reaction(emoji: "💪", count: 3),
            Reaction(emoji: "😊", count: 4)
        ])
        let rows4 = view4.calculateReactionRows()
        XCTAssertEqual(rows4, 2, "4 reactions + 1 for plus button should be 2 rows")
        
        // Test with 7 reactions (8 items total)
        let view7 = createView(reactions: [
            Reaction(emoji: "👍", count: 1),
            Reaction(emoji: "🔥", count: 2),
            Reaction(emoji: "💪", count: 3),
            Reaction(emoji: "😊", count: 4),
            Reaction(emoji: "👏", count: 5),
            Reaction(emoji: "🎉", count: 6),
            Reaction(emoji: "✨", count: 7)
        ])
        let rows7 = view7.calculateReactionRows()
        XCTAssertEqual(rows7, 2, "7 reactions + 1 for plus button should be 2 rows")
    }
    
    func testFormattedTimestamp() {
        let view = createView(reactions: [])
        
        // Test today
        let today = Date()
        XCTAssertEqual(view.formattedTimestamp(for: today), "Today")
        
        // Test yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertEqual(view.formattedTimestamp(for: yesterday), "Yesterday")
        
        // Test older date should be before
        let olderDate = Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 25))!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let expected = formatter.string(from: olderDate)
        XCTAssertEqual(view.formattedTimestamp(for: olderDate), expected)
    }
}
