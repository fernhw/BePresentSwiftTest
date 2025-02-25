//
//  ReactionTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent // Replace with your actual module name

class ReactionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Test initialization and property values
    func testInitialization() {
        let reaction = Reaction(emoji: "👍", count: 5)
        
        XCTAssertEqual(reaction.emoji, "👍")
        XCTAssertEqual(reaction.count, 5)
    }
    
    // Test computed property: id
    func testId() {
        let reaction = Reaction(emoji: "🔥", count: 3)
        
        XCTAssertEqual(reaction.id, "🔥")
    }
    
    // Test Equatable conformance
    func testEquatable() {
        let reaction1 = Reaction(emoji: "👍", count: 5)
        let reaction2 = Reaction(emoji: "👍", count: 5)
        let reaction3 = Reaction(emoji: "👍", count: 3)
        let reaction4 = Reaction(emoji: "🔥", count: 5)
        
        XCTAssertEqual(reaction1, reaction2)
        XCTAssertNotEqual(reaction1, reaction3)
        XCTAssertNotEqual(reaction1, reaction4)
    }
    
    // Test encoding
    func testEncoding() throws {
        let reaction = Reaction(emoji: "👍", count: 5)
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(reaction)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        let expectedJsonContains = [
            "\"emoji\":\"👍\"",
            "\"count\":5"
        ]
        
        for expected in expectedJsonContains {
            XCTAssertTrue(jsonString.contains(expected), "JSON should contain: \(expected)")
        }
    }
    
    // Test decoding
    func testDecoding() throws {
        let jsonString = """
        {
            "emoji": "🔥",
            "count": 3
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let reaction = try decoder.decode(Reaction.self, from: jsonData)
        
        XCTAssertEqual(reaction.emoji, "🔥")
        XCTAssertEqual(reaction.count, 3)
    }
    
    // Test encoding and decoding round trip
    func testCodableRoundTrip() throws {
        let originalReaction = Reaction(emoji: "😊", count: 10)
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(originalReaction)
        
        let decoder = JSONDecoder()
        let decodedReaction = try decoder.decode(Reaction.self, from: jsonData)
        
        XCTAssertEqual(originalReaction, decodedReaction)
    }
}
