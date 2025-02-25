//
//  ImageCacheTests.swift
//  BePresent
//
//  Created by Fernando Holguin on 25/2/25.
//
import XCTest
@testable import BePresent // Replace with your module name
import Alamofire
import UIKit

// Protocol for dependency injection
protocol ImageRequestHandler {
    func request(_ url: String, completion: @escaping (DataResponse<Data, AFError>) -> Void)
}

// Real implementation using Alamofire
class AlamofireImageRequestHandler: ImageRequestHandler {
    func request(_ url: String, completion: @escaping (DataResponse<Data, AFError>) -> Void) {
        AF.request(url).responseData(completionHandler: completion)
    }
}

// Updated ImageCache with closure-based request handler
class ImageCache {
    static let shared = ImageCache()
    
    internal let cache = NSCache<NSString, UIImage>()
    private let requestHandler: ImageRequestHandler
    
    init(requestHandler: ImageRequestHandler = AlamofireImageRequestHandler()) {
        self.requestHandler = requestHandler
    }
    
    func getImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSString) {
            completion(cachedImage)
            return
        }
        
        requestHandler.request(url) { response in
            switch response.result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: url as NSString)
                    completion(image)
                } else {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}

// Mock ImageRequestHandler for testing


class ImageCacheTests: XCTestCase {
    
    var imageCache: ImageCache!
    var mockRequestHandler: MockImageRequestHandler!
    
    override func setUp() {
        super.setUp()
        mockRequestHandler = MockImageRequestHandler()
        imageCache = ImageCache(requestHandler: mockRequestHandler)
    }
    
    override func tearDown() {
        imageCache = nil
        mockRequestHandler = nil
        super.tearDown()
    }
    
    func testGetImageFromCache() {
        let url = "https://example.com/test.png"
        let testImage = UIImage(systemName: "star")!
        imageCache.cache.setObject(testImage, forKey: url as NSString)
        let expectation = self.expectation(description: "Image retrieved from cache")
        
        imageCache.getImage(for: url) { image in
            XCTAssertNotNil(image)
            XCTAssertEqual(image?.pngData(), testImage.pngData())
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetImageFetchSuccess() {
        // Arrange
        let url = "https://example.com/test.png"
        let testImage = UIImage(systemName: "star")!
        let imageData = testImage.pngData()!
        mockRequestHandler.mockResult = .success(imageData)
        let expectation = self.expectation(description: "Image fetched successfully")

        // Act
        imageCache.getImage(for: url) { image in
            
           XCTAssertNotNil(image)
           let cachedImage = self.imageCache.cache.object(forKey: url as NSString)
            
           // counting the bytes like a robot
           XCTAssertEqual(image?.pngData()?.count, imageData.count, "Fetched image byte count should match")
           XCTAssertEqual(cachedImage?.pngData()?.count, imageData.count, "Cached image byte count should match")
           
           expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
    
    func testGetImageFetchInvalidData() {
        let url = "https://example.com/invalid.png"
        mockRequestHandler.mockResult = .success(Data()) // Empty data
        let expectation = self.expectation(description: "Fetch with invalid data")
        
        imageCache.getImage(for: url) { image in
            XCTAssertNil(image)
            XCTAssertNil(self.imageCache.cache.object(forKey: url as NSString))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testGetImageFetchFailure() {
        let url = "https://example.com/error.png"
        let mockError = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: 404))
        mockRequestHandler.mockResult = .failure(mockError)
        let expectation = self.expectation(description: "Fetch fails with error")
        
        imageCache.getImage(for: url) { image in
            XCTAssertNil(image)
            XCTAssertNil(self.imageCache.cache.object(forKey: url as NSString))
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
