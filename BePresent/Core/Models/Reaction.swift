//
//  Reaction.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//


import Foundation

struct Reaction: Codable, Identifiable, Equatable {
    let emoji: String
    var count: Int
    
    var id: String { emoji }
    
    static func == (lhs: Reaction, rhs: Reaction) -> Bool {
        return lhs.emoji == rhs.emoji && lhs.count == rhs.count
    }
}
