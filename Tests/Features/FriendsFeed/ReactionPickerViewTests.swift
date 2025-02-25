//
//  ReactionPickerViewTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent
import SwiftUI

class ReactionPickerViewTests: XCTestCase {
    
    let sampleActivity = FriendActivity(
        userId: "1",
        imageUrl: "https://example.com/test.png",
        name: "Test User",
        timestamp: Date(),
        activityTitle: "Test Activity",
        activityMainEmoji: "🔥",
        reactions: []
    )
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testEmojiSelection() {
        // Arrange
        var selectedEmoji: String?
        let view = ReactionPickerView(
            activity: sampleActivity,
            selectedEmoji: { emoji in selectedEmoji = emoji }
        )
        let expectation = self.expectation(description: "Emoji selected")
        
        let emoji = "👍"
        view.selectedEmoji(emoji) // Directly call the closure as a proxy for tap
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(selectedEmoji, "👍")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
