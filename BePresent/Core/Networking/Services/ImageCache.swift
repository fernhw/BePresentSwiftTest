//
//  ImageCache.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//


import Alamofire
import UIKit

protocol ImageRequestHandler {
    func request(_ url: String) -> DataRequest
}

class AlamofireImageRequestHandler: ImageRequestHandler {
    func request(_ url: String) -> DataRequest {
        return AF.request(url)
    }
}

class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let requestHandler: ImageRequestHandler
    
    init(requestHandler: ImageRequestHandler = AlamofireImageRequestHandler()) {
        self.requestHandler = requestHandler
    }
    
    func getImage(for url: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSString) {
            completion(cachedImage)
            return
        }
        
        requestHandler.request(url).responseData { response in
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
