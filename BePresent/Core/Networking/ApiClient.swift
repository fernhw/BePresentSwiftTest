//
//  ApiClient.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

/* I created this to handle all the network requests in the app. It uses Alamofire to make the requests and returns the response as a Decodable object. */
import Foundation
import Alamofire

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case networkUnavailable
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response"
        case .networkUnavailable: return "No network connection"
        case .serverError(let statusCode): return "Server error: \(statusCode)"
        }
    }
}

protocol APIClientProtocol {
    func request<T: Decodable>(_ url: String) async throws -> T
}

class APIClient: APIClientProtocol {
    private let networkMonitor: NetworkMonitor
    private let session: Session
    private let decoder: JSONDecoder
    
    init(networkMonitor: NetworkMonitor = .shared, session: Session = .default) {
        self.networkMonitor = networkMonitor
        self.session = session
        self.decoder = JSONDecoder()
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
        }
    }
    
    func request<T: Decodable>(_ url: String) async throws -> T {
        guard networkMonitor.isConnected else { throw NetworkError.networkUnavailable }
        let response = await session.request(url, method: .get)
            .validate()
            .serializingDecodable(T.self, decoder: decoder)
            .response
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON: \(jsonString)")
        }
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            if case .explicitlyCancelled = error {
                throw CancellationError()
            }
            print("Decoding error: \(error)")
            if let statusCode = response.response?.statusCode, 400...599 ~= statusCode {
                throw NetworkError.serverError(statusCode: statusCode)
            }
            throw error
        }
    }
}

// Custom error for cancellation
struct CancellationError: Error {}
