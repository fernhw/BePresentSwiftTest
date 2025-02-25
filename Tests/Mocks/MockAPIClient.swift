//
//  MockAPIClient.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import Alamofire
@testable import BePresent

class MockAPIClient: APIClientProtocol {
    var shouldSucceed: Bool
    var mockActivities: [FriendActivity]?
    var mockError: Error?
    
    init(shouldSucceed: Bool, mockActivities: [FriendActivity]? = nil, mockError: Error? = nil) {
        self.shouldSucceed = shouldSucceed
        self.mockActivities = mockActivities
        self.mockError = mockError
    }
    
    func request<T: Decodable>(_ endpoint: String) async throws -> T {
        if shouldSucceed {
            if let activities = mockActivities as? T {
                return activities
            }
            throw AFError.responseValidationFailed(reason: .dataFileNil)
        } else {
            throw mockError ?? AFError.responseValidationFailed(reason: .dataFileNil)
        }
    }
}
