//
//  NetworkMonitor.swift
//  BePresent
//
//  Created by Fernando Holguin on 23/2/25.
//

import Network
import Combine

// Standard stuff I'd put a toast message if detected since it IS a rest app this is essential for its core functionalities.

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published private(set) var isConnected = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
