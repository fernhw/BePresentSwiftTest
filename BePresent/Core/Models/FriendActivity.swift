//
//  FriendActivity.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

// FriendActivity.swift
import Foundation

struct FriendActivity: Codable, Identifiable, Equatable {
    let userId: String
    let imageUrl: String
    let name: String
    let timestamp: Date
    let activityTitle: String
    let activityMainEmoji: String
    var reactions: [Reaction]
    
    var imageURL: URL? {
        URL(string: imageUrl)
    }
    
    var id: String { userId + timestamp.ISO8601Format() }
    
    enum CodingKeys: String, CodingKey {
        case userId, imageUrl, name, timestamp, activityTitle, activityMainEmoji, reactions
    }

    init(
         userId: String,
         imageUrl: String,
         name: String,
         timestamp: Date,
         activityTitle: String,
         activityMainEmoji: String,
         reactions: [Reaction]
     ) {
         self.userId = userId
         self.imageUrl = imageUrl
         self.name = name
         self.timestamp = timestamp
         self.activityTitle = activityTitle
         self.activityMainEmoji = activityMainEmoji
         self.reactions = reactions
     }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        imageUrl = try container.decode(String.self, forKey: .imageUrl) // Decode as String
        name = try container.decode(String.self, forKey: .name)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        activityTitle = try container.decode(String.self, forKey: .activityTitle)
        activityMainEmoji = try container.decode(String.self, forKey: .activityMainEmoji)
        
        let reactionDict = try container.decodeIfPresent([String: Int].self, forKey: .reactions) ?? [:]
        reactions = reactionDict.map { Reaction(emoji: $0.key, count: $0.value) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(name, forKey: .name)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(activityTitle, forKey: .activityTitle)
        try container.encode(activityMainEmoji, forKey: .activityMainEmoji)
        
        let reactionDict = Dictionary(uniqueKeysWithValues: reactions.map { ($0.emoji, $0.count) })
        try container.encode(reactionDict, forKey: .reactions)
    }
}

