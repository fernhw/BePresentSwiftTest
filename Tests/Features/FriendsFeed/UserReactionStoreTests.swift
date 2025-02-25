//
//  UserReactionStoreTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent

class UserReactionStoreTests: XCTestCase {
    
    var store: UserReactionStore!
    
    override func setUp() {
        super.setUp()
        store = UserReactionStore()
    }
    
    override func tearDown() {
        store = nil
        super.tearDown()
    }
    
    func testGenerateKey() {
        let key1 = store.generateKey(userId: "user1", activityTitle: "Test Activity")
        let key2 = store.generateKey(userId: "user1", activityTitle: "Test Activity")
        let key3 = store.generateKey(userId: "user2", activityTitle: "Test Activity")
        
        XCTAssertEqual(key1, key2, "Same inputs should generate same key")
        XCTAssertNotEqual(key1, key3, "Different userId should generate different key")
    }
    
    func testAddReaction() {
        store.addReaction("👍", userId: "user1", activityTitle: "Test Activity")
        
        let reactions = store.getUserReactions(userId: "user1", activityTitle: "Test Activity")
        XCTAssertEqual(reactions, ["👍"])
    }
    
    func testRemoveReaction() {
        store.addReaction("👍", userId: "user1", activityTitle: "Test Activity")
        store.addReaction("🔥", userId: "user1", activityTitle: "Test Activity")
        store.removeReaction("👍", userId: "user1", activityTitle: "Test Activity")
        
        let reactions = store.getUserReactions(userId: "user1", activityTitle: "Test Activity")
        XCTAssertEqual(reactions, ["🔥"])
    }
    
    func testRemoveLastReaction() {
        store.addReaction("👍", userId: "user1", activityTitle: "Test Activity")
        store.removeReaction("👍", userId: "user1", activityTitle: "Test Activity")
        
        let reactions = store.getUserReactions(userId: "user1", activityTitle: "Test Activity")
        XCTAssertTrue(reactions.isEmpty)
    }
}
