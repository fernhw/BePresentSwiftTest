//
//  FriendsFeedViewModel.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//


import Foundation

@MainActor
class FriendsFeedViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded([FriendActivity])
        case error(String)
        
        static func ==(lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let lhsActivities), .loaded(let rhsActivities)):
                return lhsActivities == rhsActivities
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    // internal only for tests
    @Published var state: State = .idle
    @Published var showReactionPicker = false // Controls picker visibility
    
    private let repository: FriendsActivityRepositoryProtocol
    private let userReactionStore: UserReactionStore
    private let reactionEmojis = Constants.reactionEmojis // Assuming defined elsewhere
    
    init(
        repository: FriendsActivityRepositoryProtocol = FriendsActivityRepository(apiClient: APIClient()),
        userReactionStore: UserReactionStore = UserReactionStore()
    ) {
        self.repository = repository
        self.userReactionStore = userReactionStore
        Task { await fetchActivities() }
    }
    
    func fetchActivities() async {
        state = .loading
        do {
            var activities = try await repository.fetchFriendsActivity()
            for i in activities.indices {
                let userReactions = getUserReactionsFromServer(for: activities[i]) // Preload user reactions
                for emoji in userReactions {
                    userReactionStore.addReaction(emoji, userId: activities[i].userId, activityTitle: activities[i].activityTitle)
                }
                activities[i].reactions = getAllReactions(for: activities[i])
            }
            state = .loaded(activities)
        } catch is CancellationError {
            print("Request cancelled, awaiting new data...")
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func fetchActivitiesSafely() async {
        state = .loading
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        await Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                var activities = try await self.repository.fetchFriendsActivity()
                for i in activities.indices {
                    activities[i].reactions = await self.getAllReactions(for: activities[i])
                }
                await MainActor.run {
                    self.state = .loaded(activities)
                }
            } catch {
                print("Refresh error (non-cancellable): \(error)")
                await MainActor.run {
                    self.state = .error("Failed to refresh: \(error.localizedDescription)")
                }
            }
        }.value
    }
    
    func addReaction(_ emoji: String, to activity: FriendActivity) {
        guard case .loaded(var activities) = state,
              let index = activities.firstIndex(of: activity) else { return }
        
        let beforeReactions = activities[index].reactions.map { "\($0.emoji):\($0.count)" }.joined(separator: ", ")
        let beforeUserReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        print("Adding emoji: \(emoji) to activity '\(activity.activityTitle)' (userId: \(activity.userId))")
        print("Before - Total Reactions: [\(beforeReactions)]")
        print("Before - User Reactions: \(beforeUserReactions)")
        
        if let reactionIndex = activities[index].reactions.firstIndex(where: { $0.emoji == emoji }) {
            activities[index].reactions[reactionIndex].count += 1
        } else {
            activities[index].reactions.append(Reaction(emoji: emoji, count: 1))
        }
        userReactionStore.addReaction(emoji, userId: activity.userId, activityTitle: activity.activityTitle)
        
        let afterReactions = activities[index].reactions.map { "\($0.emoji):\($0.count)" }.joined(separator: ", ")
        let afterUserReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        print("After - Total Reactions: [\(afterReactions)]")
        print("After - User Reactions: \(afterUserReactions)")
        
        state = .loaded(activities)
    }
    
    func removeReaction(_ emoji: String, from activity: FriendActivity) {
        guard case .loaded(var activities) = state,
              let index = activities.firstIndex(of: activity),
              let reactionIndex = activities[index].reactions.firstIndex(where: { $0.emoji == emoji }) else { return }
        
        let beforeReactions = activities[index].reactions.map { "\($0.emoji):\($0.count)" }.joined(separator: ", ")
        let beforeUserReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        print("Removing emoji: \(emoji) from activity '\(activity.activityTitle)' (userId: \(activity.userId))")
        print("Before - Total Reactions: [\(beforeReactions)]")
        print("Before - User Reactions: \(beforeUserReactions)")
        
        if activities[index].reactions[reactionIndex].count > 1 {
            activities[index].reactions[reactionIndex].count -= 1
        } else {
            activities[index].reactions.remove(at: reactionIndex)
        }
        userReactionStore.removeReaction(emoji, userId: activity.userId, activityTitle: activity.activityTitle)
        
        let afterReactions = activities[index].reactions.map { "\($0.emoji):\($0.count)" }.joined(separator: ", ")
        let afterUserReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        print("After - Total Reactions: [\(afterReactions)]")
        print("After - User Reactions: \(afterUserReactions)")
        
        state = .loaded(activities)
    }
    
    func userHasReacted(with emoji: String, to activity: FriendActivity) -> Bool {
        let userReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        return userReactions.contains(emoji)
    }
    
    func getAllReactions(for activity: FriendActivity) -> [Reaction] {
        let userReactions = userReactionStore.getUserReactions(userId: activity.userId, activityTitle: activity.activityTitle)
        var combinedReactions = activity.reactions
        
        for emoji in userReactions {
            if let index = combinedReactions.firstIndex(where: { $0.emoji == emoji }) {
                combinedReactions[index].count += 1
            } else {
                combinedReactions.append(Reaction(emoji: emoji, count: 1))
            }
        }
        return combinedReactions
    }
    
    private func getUserReactionsFromServer(for activity: FriendActivity) -> Set<String> {
        // Placeholder: Adjust if server data flags user reactions
        return Set()
    }
}
