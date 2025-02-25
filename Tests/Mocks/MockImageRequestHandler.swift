//
//  MockImageRequestHandler.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//

import XCTest
@testable import BePresent // Replace with your module name
import Alamofire


class MockImageRequestHandler: ImageRequestHandler {
    var mockResult: Result<Data, AFError>?
    
    func request(_ url: String, completion: @escaping (DataResponse<Data, AFError>) -> Void) {
        guard let result = mockResult else {
            fatalError("Mock result not set")
        }
        let data: Data? = try? result.get() // Extract data if success, nil if failure
        let response = DataResponse(
            request: nil,
            response: nil,
            data: data,
            metrics: nil,
            serializationDuration: 0,
            result: result
        )
        DispatchQueue.main.async {
            completion(response)
        }
    }
}
