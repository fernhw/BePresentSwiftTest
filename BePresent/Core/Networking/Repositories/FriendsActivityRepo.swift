
//
//  FriendsActivityRepo.swift
//  BePresent Test
//
//  Created by Fernando Holguin on 23/2/25.
//


/**
For reviewers:

 This file is responsible for handling the core functionality of our application's networking layer.
 It contains the repository that fetches friends' activities from the API.
 
 By splitting the API calls into single-use files, I aim to make the codebase more scalable and maintainable.
 This approach allows us to easily locate and fix errors, as well as to test individual components effectively.
 
 The purpose of this file is to encapsulate the network request and data handling! This way, we can easily swap out the networking layer without affecting the rest of the application. Common practice prevents a singletons pattern, which can lead to tight coupling and make testing difficult.

 */


import Foundation
import Alamofire


// In swift this is a common practice Protocol Oriented Programming or POP for short
// This is a protocol that defines FriendActivityRepositoryProtocol and its methods its also used to define the dependencies of the class
// This is a good practice because it allows us to easily swap out the dependencies of the class and easily test the class

protocol FriendsActivityRepositoryProtocol {
    
    // This would be in pieces for a larger project segmented by the different endpoints loading 10 or more 'posts' or in this case 'FriendActivity' objects
     
    func fetchFriendsActivity() async throws -> [FriendActivity]
}

class FriendsActivityRepository: FriendsActivityRepositoryProtocol {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func fetchFriendsActivity() async throws -> [FriendActivity] {
        let activities: [FriendActivity] = try await apiClient.request(Constants.friendsActivityEndpoint)
        return activities.sorted { $0.timestamp > $1.timestamp }
    }
}






