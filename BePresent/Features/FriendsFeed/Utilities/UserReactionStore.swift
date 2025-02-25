//
//  UserReactionStore.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//


// we cannot interact with a server, and no postIDs, only user IDs and titles to create a unique hash.

class UserReactionStore {
    private var reactionMap: [String: Set<String>] = [:] // Key: hashed(userId + activityTitle), Value: Set of emojis
    
    func generateKey(userId: String, activityTitle: String) -> String {
        // Combine userId and activityTitle with a delimiter and use hashValue for simplicity
        let combined = "\(userId)_\(activityTitle)"
        return String(combined.hashValue)
    }
    
    func addReaction(_ emoji: String, userId: String, activityTitle: String) {
        let key = generateKey(userId: userId, activityTitle: activityTitle)
        var reactions = reactionMap[key] ?? Set()
        reactions.insert(emoji)
        reactionMap[key] = reactions
    }
    
    func removeReaction(_ emoji: String, userId: String, activityTitle: String) {
        let key = generateKey(userId: userId, activityTitle: activityTitle)
        guard var reactions = reactionMap[key] else { return }
        reactions.remove(emoji)
        if reactions.isEmpty {
            reactionMap.removeValue(forKey: key)
        } else {
            reactionMap[key] = reactions
        }
    }
    
    func getUserReactions(userId: String, activityTitle: String) -> Set<String> {
        let key = generateKey(userId: userId, activityTitle: activityTitle)
        return reactionMap[key] ?? Set()
    }
}
